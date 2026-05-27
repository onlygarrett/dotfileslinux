import os
import zipfile
import pathspec
from pathlib import Path

# --- CONFIGURATION ---
TARGET_DIR = "."  # Current directory
OUTPUT_ZIP = "repo_context.zip"
# Additional ignores specific to LLM context (files that are noise)
ALWAYS_IGNORE = [
    ".git",
    "node_modules",
    "venv",
    ".venv",
    "__pycache__",
    "dist",
    "build",
    "coverage",
    ".idea",
    ".vscode",
    "package-lock.json",
    "yarn.lock",
    "poetry.lock",
    "*.svg",
    "*.png",
    "*.jpg",
    "*.pyc",
    ".DS_Store",
]
# ---------------------


def load_gitignore(root_dir):
    gitignore = root_dir / ".gitignore"
    patterns = ALWAYS_IGNORE.copy()
    if gitignore.exists():
        with open(gitignore, "r") as f:
            patterns.extend(f.read().splitlines())
    return pathspec.PathSpec.from_lines("gitwildmatch", patterns)


def pack_repo():
    root = Path(TARGET_DIR).resolve()
    spec = load_gitignore(root)

    with zipfile.ZipFile(OUTPUT_ZIP, "w", zipfile.ZIP_DEFLATED) as zf:
        print(f"📦 Packing repository from: {root}")

        for file_path in root.rglob("*"):
            if not file_path.is_file():
                continue

            rel_path = file_path.relative_to(root)
            str_path = str(rel_path)

            # Check against gitignore and hardcoded ignores
            if spec.match_file(str_path):
                continue

            # Skip the output file itself
            if str_path == OUTPUT_ZIP:
                continue

            try:
                zf.write(file_path, arcname=str_path)
                print(f"  + {str_path}")
            except Exception as e:
                print(f"  ! Error reading {str_path}: {e}")

    print(f"\n✅ Done! Created {OUTPUT_ZIP}")
    print(f"👉 Upload this file to Open WebUI > Workspace > Knowledge")


if __name__ == "__main__":
    pack_repo()
