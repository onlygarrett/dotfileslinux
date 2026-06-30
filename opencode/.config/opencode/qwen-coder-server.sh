#!/usr/bin/env bash
# Serve Qwen3-Coder-30B-A3B-Instruct for opencode via the CUDA13 llama.cpp container.
# CUDA 13 / native Blackwell sm_120, MoE experts offloaded to CPU.
# OpenAI-compatible endpoint at http://127.0.0.1:8080/v1 (matches opencode provider "llama-cpp").
#
# Usage:
#   qwen-coder-server.sh            # run in foreground (Ctrl-C to stop, frees VRAM)
#   qwen-coder-server.sh -d         # run detached; stop with: podman stop qwen-coder
#
# First run downloads the model (~18GB) into ~/.cache/huggingface (persists across restarts).
# Measured on RTX 5070 Ti Laptop 12GB: --n-cpu-moe 40 -> ~8.1GB VRAM used (~3.6GB free),
#   ~212 tok/s prompt eval, ~37-41 tok/s generation.
# Tuning: --n-cpu-moe N keeps experts of the first N (of 48) layers on CPU; the rest go on GPU.
#   LOWER N = more experts on GPU = faster, but more VRAM. Watch `nvidia-smi`; keep ~2GB free
#   for the desktop. N=30 was too tight (301MB free) on this machine; N=40 is the safe balance.
set -euo pipefail

DETACH=()
[[ "${1:-}" == "-d" ]] && DETACH=(-d)

exec podman run --rm --name qwen-coder "${DETACH[@]}" \
  --device nvidia.com/gpu=all \
  --network host \
  -v "$HOME/.cache/huggingface:/root/.cache/huggingface:z" \
  ghcr.io/ggml-org/llama.cpp:server-cuda13 \
  -hf unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:UD-Q4_K_XL \
  --alias qwen3-coder-30b \
  --host 127.0.0.1 --port 8080 \
  --n-gpu-layers 99 \
  --n-cpu-moe 40 \
  --parallel 1 \
  --ctx-size 65536 \
  --flash-attn on \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja \
  --temp 0.7 --top-p 0.8 --top-k 20 --min-p 0.0 --repeat-penalty 1.05 \
  --no-context-shift
