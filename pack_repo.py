import os
import zipfile
import pathspec
from pathlib import Path

# --- CONFIGURATION ---
TARGET_DIR = "."  # Current directory
OUTPUT_ZIP = "repo_context.zip"
ALWAYS_IGNORE = [
    ".git",
    "node_modules",
    "venv",
    ".venv",
    "__pycache__",
    ".DS_Store",
    "*.wallpaper_current",
    "*.wallpaper_modified",
    "*.png",
    "*.jpg",
    "*.jpeg",
    "*.svg",
    "*.ico",
    "*.tmTheme",
    "*.css",
    "*.rasi",
    "kitty-themes",
    "waybar/style",
    "package-lock.json",
    "yarn.lock",
    "atuin-receipt.json",
    "*.pyc",
    "*.sh.bak",
    ".initial_startup_done",
]


def load_gitignore(root_dir):
    gitignore = root_dir / ".gitignore"
    patterns = ALWAYS_IGNORE.copy()
    if gitignore.exists():
        with open(gitignore, "r") as f:
            patterns.extend(f.read().splitlines())
    return pathspec.PathSpec.from_lines("gitwildmatch", patterns)


def pack_repo_fixed():
    root = Path(TARGET_DIR).resolve()
    spec = load_gitignore(root)

    try:
        # Use a more explicit ZIP creation approach
        with zipfile.ZipFile(
            OUTPUT_ZIP, "w", zipfile.ZIP_DEFLATED, compresslevel=6
        ) as zf:
            print(f"📦 Packing repository from: {root}")

            for file_path in root.rglob("*"):
                if not file_path.is_file():
                    continue

                rel_path = file_path.relative_to(root)
                str_path = str(rel_path)

                # Skip ignored files
                if spec.match_file(str_path):
                    continue

                # Skip output file itself
                if str_path == OUTPUT_ZIP:
                    continue

                try:
                    # More explicit approach for better compatibility
                    with open(file_path, "rb") as f:
                        data = f.read()
                    zf.writestr(str_path, data)
                    print(f"  + {str_path}")
                except Exception as e:
                    print(f"  ! Error reading {str_path}: {e}")

        # Try to ensure compatibility by adding manifest
        with zipfile.ZipFile(OUTPUT_ZIP, "a") as zf:
            manifest_data = """{
    "type": "openwebui_context",
    "version": "1.0",
    "description": "Repository context for Open WebUI knowledge base"
}"""
            zf.writestr("manifest.json", manifest_data)
            print(f"  + manifest.json")

        print(f"\n✅ Done! Created {OUTPUT_ZIP}")

    except Exception as e:
        print(f"❌ Error creating ZIP: {e}")


if __name__ == "__main__":
    pack_repo_fixed()
