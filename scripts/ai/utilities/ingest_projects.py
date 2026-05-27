import os
import hashlib
import argparse
from typing import List

import chromadb
from chromadb.config import Settings
from sentence_transformers import SentenceTransformer
from tqdm import tqdm

DEFAULT_ALLOWED_EXTS = {
    ".md",
    ".txt",
    ".rst",
    ".html",
    ".py",
    ".js",
    ".ts",
    ".jsx",
    ".tsx",
    ".go",
    ".rs",
    ".java",
    ".c",
    ".cpp",
    ".h",
    ".hpp",
    ".json",
    ".yml",
    ".yaml",
    ".sh",
    ".bash",
    ".zsh",
    ".toml",
    ".ini",
    ".cfg",
    ".conf",
    ".sql",
}

CHUNK_SIZE = 600
CHUNK_OVERLAP = 120
EMBED_MODEL_NAME = "sentence-transformers/all-MiniLM-L6-v2"
CHROMA_DIR = "./chroma_db_projects"
COLLECTION_NAME = "projects"


def iter_files(root_dir: str, allowed_exts: set) -> List[str]:
    files = []
    for base, _, filenames in os.walk(root_dir):
        for fn in filenames:
            ext = os.path.splitext(fn)[1].lower()
            if ext in allowed_exts:
                files.append(os.path.join(base, fn))
    return files


def read_file(path: str) -> str:
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            return f.read()
    except Exception as e:
        print(f"[WARN] Could not read {path}: {e}")
        return ""


def chunk_text(text: str, chunk_size: int, overlap: int):
    chunks = []
    start = 0
    n = len(text)
    while start < n:
        end = min(n, start + chunk_size)
        chunk = text[start:end]
        if chunk.strip():
            chunks.append(chunk)
        start = end - overlap
        if start < 0:
            start = 0
    return chunks


def file_id(path: str) -> str:
    return hashlib.sha256(path.encode("utf-8")).hexdigest()


def chunk_id(file_id_str: str, chunk_idx: int) -> str:
    return f"{file_id_str}-{chunk_idx}"


def main():
    parser = argparse.ArgumentParser(description="Ingest project files into Chroma.")
    parser.add_argument(
        "--root", type=str, required=True, help="Root directory of projects"
    )
    parser.add_argument(
        "--chroma_dir", type=str, default=CHROMA_DIR, help="Chroma DB directory"
    )
    parser.add_argument(
        "--collection", type=str, default=COLLECTION_NAME, help="Collection name"
    )
    parser.add_argument(
        "--chunk_size", type=int, default=CHUNK_SIZE, help="Chunk size (chars)"
    )
    parser.add_argument(
        "--chunk_overlap", type=int, default=CHUNK_OVERLAP, help="Chunk overlap (chars)"
    )
    parser.add_argument(
        "--allowed_exts",
        type=str,
        nargs="*",
        default=list(DEFAULT_ALLOWED_EXTS),
        help="Allowed file extensions",
    )
    args = parser.parse_args()

    allowed_exts = set([ext.lower() for ext in args.allowed_exts])

    print(f"[INFO] Scanning {args.root} ...")
    files = iter_files(args.root, allowed_exts)
    print(f"[INFO] Found {len(files)} candidate files")

    client = chromadb.PersistentClient(
        path=args.chroma_dir, settings=Settings(anonymized_telemetry=False)
    )
    collection = client.get_or_create_collection(
        name=args.collection, metadata={"description": "Project knowledge base"}
    )

    model = SentenceTransformer(EMBED_MODEL_NAME)

    to_upsert_ids = []
    to_upsert_docs = []
    to_upsert_metas = []

    for path in tqdm(files, desc="Processing files"):
        text = read_file(path)
        if not text.strip():
            continue
        chunks = chunk_text(text, args.chunk_size, args.chunk_overlap)
        fid = file_id(path)
        for idx, chunk in enumerate(chunks):
            cid = chunk_id(fid, idx)
            to_upsert_ids.append(cid)
            to_upsert_docs.append(chunk)
            to_upsert_metas.append({"source_path": path, "chunk_index": idx})

    if not to_upsert_docs:
        print("[WARN] No content to upsert. Exiting.")
        return

    print(f"[INFO] Embedding {len(to_upsert_docs)} chunks...")
    embeddings = model.encode(
        to_upsert_docs, show_progress_bar=True, convert_to_numpy=True
    )

    print("[INFO] Upserting into Chroma...")
    collection.upsert(
        ids=to_upsert_ids,
        documents=to_upsert_docs,
        embeddings=embeddings,
        metadatas=to_upsert_metas,
    )
    print("[INFO] Done. Chroma DB populated.")


if __name__ == "__main__":
    main()
