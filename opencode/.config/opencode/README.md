# Local LLM + OpenCode Setup

Personal AI coding environment running on Fedora 44 / Hyprland.
Built around [OpenCode](https://opencode.ai) as the coding agent shell, with a mix of local and cloud models,
semantic code tools, MCP servers, and process-oriented agent skills.

---

## My Hardware

| Component | Spec |
|-----------|------|
| GPU | RTX 5070 Ti Laptop 12GB GDDR7 (Blackwell sm_120) |
| CPU | Ryzen 9 9955HX |
| RAM | 32GB DDR5 |
| OS | Fedora 44 + Hyprland (JaKooLit dotfiles) |
| Container runtime | Podman 5.8.2 + CDI (`/etc/cdi/nvidia.yaml`) |

---

## Models

### Primary (cloud)
| Model | Provider key | Use |
|-------|-------------|-----|
| `claude-sonnet-4.6` | `github-copilot/claude-sonnet-4.6` | Default — all general coding, planning, review |

### Local — Ollama
| Model | Key | Context | Use |
|-------|-----|---------|-----|
| Qwen3-14B | `ollama/qwen3:14b` | 128k | General chat, medium tasks |
| Qwen3-8B | `ollama/qwen3:8b` | 40k | Small model (tool calls, quick tasks) |

Ollama endpoint: `http://localhost:11434/v1`

### Local — llama.cpp container (Qwen3-Coder-30B)
| Detail | Value |
|--------|-------|
| Model | `unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:UD-Q4_K_XL` (~18GB) |
| Quant | UD-Q4_K_XL |
| Context | 65536 tokens |
| VRAM | ~8.1GB (3.6GB free for desktop) |
| Speed | ~212 tok/s prompt, ~37–41 tok/s generation |
| Endpoint | `http://127.0.0.1:8080/v1` |
| Provider key | `llama-cpp/qwen3-coder-30b` |

The model runs in a Podman container using the official CUDA 13 llama.cpp image with CDI GPU passthrough.
MoE expert layers for the first 40 transformer layers run on CPU (`--n-cpu-moe 40`) — this keeps VRAM usage
safe on 12GB while keeping attention layers on GPU. Running fewer layers on CPU increases VRAM pressure;
N=30 left only 301MB free. N=40 is the stable balance.

Model cache is stored at `~/.cache/huggingface/` and is bind-mounted into the container, so it persists
across restarts and is shared with the HF CLI.

---

## Quick Start

### Start the local Qwen3-Coder container
```bash
qcup          # start detached (background)
qcdown        # stop
qcps          # check status
```

### Start JupyterLab (for Jupyter MCP)
```bash
jlup          # starts on port 8888, reads token from ~/.jupyter_token
```

### Switch models in OpenCode
Press `Ctrl+P` → "Model" to switch between providers interactively.

---

## Shell Aliases

Defined in `~/dotfiles/zsh/.zshrc`:

| Alias | Command | Description |
|-------|---------|-------------|
| `qcup` | `qwen-coder-server.sh -d` | Start Qwen3-Coder container detached |
| `qcdown` | `podman stop qwen-coder` | Stop and remove container |
| `qcps` | `podman ps --filter name=qwen-coder` | Check container status |
| `jlup` | `jupyter lab --port 8888 --IdentityProvider.token ... --ServerApp.disable_check_xsrf=True --no-browser` | Start JupyterLab for MCP use |

---

## Container Launch Script

**File:** `~/dotfiles/scripts/.local/bin/qwen-coder-server.sh`
(symlinked to `~/.local/bin/qwen-coder-server.sh`)

Key flags:

| Flag | Value | Reason |
|------|-------|--------|
| `--device nvidia.com/gpu=all` | CDI passthrough | Blackwell GPU access via Podman CDI |
| `--network host` | — | Exposes `127.0.0.1:8080` directly |
| `-v ~/.cache/huggingface` | bind-mount | Persists the 18GB model download |
| `-hf` | HF hub path | Downloads model on first run, cached after |
| `--n-gpu-layers 99` | all layers | Full GPU offload for non-MoE layers |
| `--n-cpu-moe 40` | 40 layers CPU | Keeps VRAM safe; see tuning note above |
| `--parallel 1` | single slot | Full 65536 ctx goes to one session |
| `--flash-attn on` | — | Faster attention on Blackwell |
| `--cache-type-k/v q8_0` | q8_0 | Compressed KV cache, fits in VRAM |
| `--jinja` | — | Enables proper chat template rendering |
| `--no-context-shift` | — | Prevents silent truncation |

**Usage:**
```bash
qwen-coder-server.sh        # foreground (Ctrl-C to stop)
qwen-coder-server.sh -d     # detached
```

> **VRAM coexistence note:** The llama.cpp container uses ~8.1GB VRAM. If you also run an Ollama GPU model
> simultaneously, they will fight for VRAM. The `small_model` (qwen3:8b) will CPU-spill, which is acceptable
> for background tasks but will be slow.

---

## MCP Servers

MCP (Model Context Protocol) servers extend the agent with external capabilities — each server exposes a
set of tools that the agent can call during a session. Configured in `~/.config/opencode/opencode.json`.

---

### Tavily — Real-Time Web Intelligence

- **Type:** Local (npx) — `tavily-mcp@latest`
- **Auth:** `TAVILY_API_KEY` from `~/.zsh_secrets`
- **Enabled:** Always (available to all agents)

**Purpose:** Gives the agent live access to the web. Without this, the agent is limited to its training
data cutoff and has no way to verify current facts, look up recent releases, or read external documentation.
Tavily returns clean, structured content rather than raw HTML, which is much easier for the model to reason over.

**Tools and when they're used:**

| Tool | What it does | When the agent uses it |
|------|-------------|----------------------|
| `tavily_search` | Semantic web search — returns top results with snippets and URLs | Looking up current library versions, recent news, error messages, blog posts |
| `tavily_extract` | Fetches and cleans full content from one or more URLs | Reading a specific docs page, release notes, or article in full |
| `tavily_crawl` | Crawls a site from a root URL, following links to a configurable depth | Pulling a whole docs section, mapping an unfamiliar site |
| `tavily_map` | Returns a sitemap of all discovered URLs without fetching full content | Finding where something lives on a large site before committing to a full crawl |
| `tavily_research` | Multi-source deep research — autonomously searches, reads, and synthesises | Answering complex questions that require synthesising across multiple sources |

**Real-world use cases:**
- "What's new in Rust 1.80?" → `tavily_search`
- "Read the full changelog at this URL" → `tavily_extract`
- "Find all the pages under /docs/api on this site" → `tavily_map`
- "Research the current state of MoE quantisation methods" → `tavily_research`

---

### Serena — Semantic Code Intelligence (LSP-backed)

- **Type:** Local (uvx) — `serena-agent`
- **Mode:** `--context ide --project-from-cwd`
- **Timeout:** 60 seconds (extended for language server cold start)
- **Enabled:** Only in `code` agent (globally gated off to protect context budget)

**Purpose:** Provides true code understanding at the symbol level, not just text search. Serena runs
language servers (LSP) in the background and exposes their intelligence as agent tools. This means the
agent can navigate a codebase the way an IDE would — following type definitions, finding all callers of
a function, getting real diagnostics — rather than just grepping for strings.

The `--project-from-cwd` flag means Serena automatically picks up whichever project is open in the current
working directory. The `--context ide` mode is optimised for interactive coding sessions where you want
low-latency, incremental responses.

**Tools and when they're used:**

| Tool | What it does | When the agent uses it |
|------|-------------|----------------------|
| `serena_find_symbol` | Locate a class, function, or variable by name across the codebase | Finding where `MyClass` is defined before reading it |
| `serena_find_referencing_symbols` | Find every symbol that references a given symbol | "What calls `processPayment`?" before refactoring it |
| `serena_find_implementations` | Find all concrete implementations of an interface or abstract method | Understanding which classes implement a given interface |
| `serena_find_declaration` | Jump to the declaration of a symbol at a specific call site | Resolving an ambiguous method call to its source |
| `serena_get_symbols_overview` | Get a structural overview of a file (classes, methods, fields) | First step when opening an unfamiliar file |
| `serena_get_diagnostics_for_file` | Fetch LSP diagnostics (errors, warnings, hints) for a file | Checking for type errors or lint issues after an edit |
| `serena_replace_symbol_body` | Replace an entire function or class body | Rewriting a method while preserving its signature |
| `serena_replace_content` | Regex or literal find-and-replace within a file | Surgical edits within a function body |
| `serena_rename_symbol` | Rename a symbol across the entire codebase | Safe rename refactors with full cross-file coverage |
| `serena_insert_before_symbol` / `serena_insert_after_symbol` | Insert code before or after a symbol definition | Adding a new method to a class, adding an import |
| `serena_write_memory` / `serena_read_memory` | Persist and recall project-specific notes across sessions | Storing architectural decisions, gotchas, conventions |
| `serena_onboarding` | Generate an initial memory file describing the project | First-time project setup; builds a persistent context map |

**Why it's gated to the `code` agent:** Each Serena tool response can be large (full symbol bodies,
cross-file reference lists). Enabling Serena globally would bloat context for every session, including
ones running on the local 65k-context Qwen3-Coder model. Gating it to `code` keeps the default and `ml`
agents lean.

**First-run note:** Serena downloads language servers (e.g. rust-analyzer, typescript-language-server,
pylsp) on first use per language. This can take 30–60 seconds. The 60s timeout in the config exists for
this reason. Subsequent starts are fast.

---

### Hugging Face — Model Hub and ML Research

- **Type:** Remote — `https://huggingface.co/mcp`
- **Auth:** `HF_TOKEN` Bearer token from `~/.zsh_secrets`
- **Enabled:** Only in `ml` agent

**Purpose:** Direct access to the Hugging Face Hub from inside the agent. Instead of manually browsing
huggingface.co, the agent can search for models, datasets, and papers programmatically, compare metadata,
inspect dataset structure, and even generate images — all within a conversation. This is the primary
research tool for ML work.

**Tools and when they're used:**

| Tool | What it does | When the agent uses it |
|------|-------------|----------------------|
| `huggingface_hub_repo_search` | Search for models or datasets by query, task type, language, sort order | "Find the best open-source instruction-tuned 7B model" |
| `huggingface_hub_repo_details` | Get full metadata, card, dataset structure, or dataset preview for a repo | Inspecting a specific model's architecture, licence, or training data |
| `huggingface_paper_search` | Semantic search over the HF papers index (arxiv papers listed on HF) | "Find recent papers on speculative decoding" |
| `huggingface_space_search` | Search for HF Spaces (demos, apps) | Finding a live demo of a model before downloading it |
| `huggingface_gr1_z_image_turbo_generate` | Generate images via the Z-Image Turbo diffusion model | Quick image generation experiments without a local diffusion setup |
| `huggingface_hf_doc_search` / `huggingface_hf_doc_fetch` | Search and retrieve HF library documentation | Looking up `transformers`, `datasets`, `diffusers` API docs |
| `huggingface_create_repo` | Create a new model, dataset, space, or bucket repo | Pushing a new model or dataset to the Hub |
| `huggingface_hf_whoami` | Confirm authenticated identity | Verifying the `HF_TOKEN` is valid |

**Why it's gated to the `ml` agent:** HF tool responses include large JSON blobs (model cards, dataset
schemas, paper abstracts). They'd fill context in sessions that have nothing to do with ML work.

---

### Jupyter — Live Notebook Execution

- **Type:** Local (uvx) — `jupyter-mcp-server@latest`
- **Connects to:** `http://localhost:8888` (JupyterLab must be running — start with `jlup`)
- **Auth:** `JUPYTER_TOKEN` (lab auth) + `MCP_TOKEN` (MCP server auth, separate)
- **Enabled:** Only in `ml` agent

**Purpose:** Bridges the agent directly into a running JupyterLab instance. The agent can create kernels,
write code into notebook cells, execute them, and read back outputs — including dataframes, plots, and
error tracebacks — all without leaving the conversation. This makes it possible to have a genuine
data-exploration or model-training loop where the agent proposes code, runs it, interprets the result,
and iterates, rather than just generating code for the user to paste manually.

**Tools and when they're used:**

| Tool | What it does | When the agent uses it |
|------|-------------|----------------------|
| `jupyter_use_notebook` | Activate a notebook for cell operations | Opening an existing notebook to work in |
| `jupyter_insert_execute_code_cell` | Insert a new code cell and immediately execute it | The main loop: write code, run it, see output |
| `jupyter_execute_cell` | Execute an existing cell by index | Re-running a cell after editing |
| `jupyter_read_cell` | Read a cell's source and outputs | Inspecting what a cell currently contains or produced |
| `jupyter_read_notebook` | Get a structural overview of all cells | Understanding a notebook's layout before editing |
| `jupyter_edit_cell_source` | Surgical find-and-replace within a cell | Fixing a variable name or correcting a line |
| `jupyter_overwrite_cell_source` | Replace an entire cell's source | Rewriting a cell completely |
| `jupyter_insert_cell` | Insert a cell at a given position (without executing) | Adding markdown documentation or setup code |
| `jupyter_delete_cell` | Delete cells by index | Removing experiments that didn't work |
| `jupyter_move_cell` | Move a cell from one position to another | Reordering cells for narrative flow |
| `jupyter_list_kernels` | List all running kernels | Diagnosing kernel state before execution |
| `jupyter_restart_notebook` | Restart the kernel | Clearing state after an OOM or corrupted namespace |
| `jupyter_list_files` | List files in the Jupyter server's filesystem | Finding notebooks to open |
| `jupyter_execute_code` | Run code directly in the kernel without saving to a cell | Quick variable inspection, `%pip install`, profiling |
| `jupyter_connect_to_jupyter` | Connect to a different Jupyter server URL/token | Switching between local and remote kernels |

**Authentication setup:** Two separate tokens are required:
1. `JUPYTER_TOKEN` — the static token JupyterLab uses to authenticate HTTP requests. Set in `~/.jupyter_token`
   and read by the `jlup` alias at startup.
2. `JUPYTER_MCP_TOKEN` (`MCP_TOKEN`) — a separate token the MCP server uses internally. Set in `~/.zsh_secrets`.

**XSRF note:** JupyterLab's XSRF protection blocks cross-origin POST requests, which the MCP server uses
to create kernels. The `jlup` alias passes `--ServerApp.disable_check_xsrf=True` to disable this check.
This is safe as long as JupyterLab is only accessible on `localhost:8888` (no `--ip 0.0.0.0`).

---

## Plugins

Configured in `opencode.json` under `"plugin"`:

### `@tarquinen/opencode-dcp@latest` — Dynamic Context Preservation
Compresses older conversation segments into dense summaries to prevent context overflow.
Keeps the context window high-signal over long sessions. Config at `~/.config/opencode/dcp.jsonc`.

### `@mohak34/opencode-notifier@latest` — Desktop Notifications
Sends `libnotify` desktop notifications when long-running tasks complete.
Config at `~/.config/opencode/opencode-notifier.json` (KDE grouping on, sound off).

---

## Agent Configuration

Two specialized agents are defined alongside the default agent:

### `code` agent
- **Description:** Code understanding and refactoring using Serena's semantic/LSP tools
- **Mode:** primary
- **Extra tools:** `serena*` (all Serena tools enabled only here)
- **Use when:** Navigating unfamiliar code, renaming symbols, finding references, getting diagnostics

### `ml` agent
- **Description:** ML work — search Hugging Face models/datasets/papers and run Jupyter notebooks
- **Mode:** primary
- **Extra tools:** `huggingface*`, `jupyter*`
- **Use when:** Exploring models, running experiments in notebooks, training/evaluation work

> **Tool gating:** `serena*`, `huggingface*`, and `jupyter*` are disabled globally in `"tools"` to protect
> the local model's 65k context budget. Each agent re-enables only what it needs.

---

## Agent Skills

Skills are process-driven instruction sets that guide the agent through specific workflows.
Loaded on demand via `Ctrl+P` → "Skill" or automatically when the task matches.

**Path:** `~/.config/opencode/agent-skills/skills/` (24 engineering skills)

### Engineering Skills
| Skill | Purpose |
|-------|---------|
| `api-and-interface-design` | Stable API and interface design |
| `browser-testing-with-devtools` | Test in real browsers via Chrome DevTools MCP |
| `ci-cd-and-automation` | CI/CD pipeline setup and automation |
| `code-review-and-quality` | Multi-axis code review |
| `code-simplification` | Refactor for clarity without changing behavior |
| `context-engineering` | Optimize agent context and rules files |
| `debugging-and-error-recovery` | Systematic root-cause debugging |
| `deprecation-and-migration` | Manage deprecation and migration |
| `documentation-and-adrs` | Record decisions and write documentation |
| `doubt-driven-development` | Adversarial review before committing to a decision |
| `frontend-ui-engineering` | Build production-quality UIs |
| `git-workflow-and-versioning` | Git branching, commits, conflict resolution |
| `idea-refine` | Divergent/convergent thinking for raw ideas |
| `incremental-implementation` | Deliver changes incrementally across files |
| `interview-me` | Extract actual requirements through structured interview |
| `observability-and-instrumentation` | Add logging, metrics, tracing, alerting |
| `performance-optimization` | Profile and fix bottlenecks |
| `planning-and-task-breakdown` | Break work into ordered, implementable tasks |
| `security-and-hardening` | Harden code against vulnerabilities |
| `shipping-and-launch` | Pre-launch checklist, staged rollout, rollback |
| `source-driven-development` | Ground decisions in official documentation |
| `spec-driven-development` | Write specs before coding |
| `test-driven-development` | Drive development with tests |
| `using-agent-skills` | Meta-skill: discover and invoke other skills |

**Path:** `~/.agents/skills/` (31 Firecrawl + general web skills)

### Web / Firecrawl Skills
| Skill | Purpose |
|-------|---------|
| `find-docs` | Fetch up-to-date library/SDK documentation |
| `firecrawl` | General web search and scraping |
| `firecrawl-agent` | AI-powered structured data extraction |
| `firecrawl-build-*` | Integrate Firecrawl into app code (scrape/search/interact/onboarding) |
| `firecrawl-company-directories` | Extract company lists from directories |
| `firecrawl-competitive-intel` | Monitor competitor pricing, features, changelogs |
| `firecrawl-crawl` | Bulk extract entire sites |
| `firecrawl-dashboard-reporting` | Pull metrics from analytics dashboards |
| `firecrawl-deep-research` | Intensive cited analytical reports |
| `firecrawl-demo-walkthrough` | Product UX walkthrough via browser |
| `firecrawl-download` | Download site as local files |
| `firecrawl-interact` | Browser automation: clicks, forms, pagination |
| `firecrawl-knowledge-base` | Build RAG-ready knowledge bases from web content |
| `firecrawl-knowledge-ingest` | Ingest JS-heavy or login-gated docs portals |
| `firecrawl-lead-gen` | Generate structured lead lists from prospect databases |
| `firecrawl-lead-research` | Pre-meeting company/person intelligence briefs |
| `firecrawl-map` | Discover all URLs on a website |
| `firecrawl-market-research` | Market, financial, industry metrics extraction |
| `firecrawl-monitor` | Detect page content changes via webhook/email |
| `firecrawl-parse` | Extract and convert local files (PDF, DOCX, XLSX) to markdown |
| `firecrawl-qa` | Exploratory QA testing of live websites |
| `firecrawl-research-index` | Find papers via semantic search |
| `firecrawl-research-papers` | Literature review and paper synthesis |
| `firecrawl-scrape` | Clean markdown from any URL |
| `firecrawl-search` | Web search with full-page content |
| `firecrawl-seo-audit` | SEO metadata, heading, and structure audit |
| `firecrawl-shop` | Product research and shopping recommendations |
| `firecrawl-website-design-clone` | Extract design system from any website |
| `firecrawl-workflows` | Outcome-focused web data workflows |

---

## Permissions

Configured in `opencode.json` under `"permission"`:

- **Read:** Allow all; deny `*.env` and `*.env.*`; explicitly allow `*.env.example`
- **External directories:** Allow all (enables tools to access files outside the workspace)
- **Bash:** Allow all; require confirmation (`ask`) for: `rm`, `rmdir`, `sudo`, `git push`,
  `git reset --hard`, `git clean`, `git checkout --`, `dd`, `mkfs*`, `chmod -R`, `chown -R`,
  `truncate`, `shutdown`, `reboot`, `> *` (output redirect)

---

## Secrets

All secrets live in `~/.zsh_secrets` (chmod 600, not tracked in dotfiles repo), sourced from `~/.zshrc`:

| Variable | Used by |
|----------|---------|
| `TAVILY_API_KEY` | Tavily MCP |
| `HF_TOKEN` | Hugging Face MCP |
| `JUPYTER_TOKEN` | JupyterLab auth (also read from `~/.jupyter_token`) |
| `JUPYTER_MCP_TOKEN` | Jupyter MCP server auth (`MCP_TOKEN`) |

`~/.jupyter_token` (chmod 600) holds the JupyterLab static token; the `jlup` alias reads it at launch.

---

## Key Files

| File | Purpose |
|------|---------|
| `~/.config/opencode/opencode.json` | Main config — providers, MCPs, plugins, tool gating, agents |
| `~/dotfiles/scripts/.local/bin/qwen-coder-server.sh` | Container launch script for Qwen3-Coder-30B |
| `~/dotfiles/zsh/.zshrc` | Shell config with `qcup`, `qcdown`, `qcps`, `jlup` aliases |
| `~/.zsh_secrets` | API keys and tokens (not in repo) |
| `~/.jupyter_token` | JupyterLab static token (chmod 600) |
| `~/.cache/huggingface/hub/` | Model cache for Qwen3-Coder-30B (~18GB) |
| `~/.venvs/jupyter/` | Python 3.11.9 venv with JupyterLab 4.4.1 |
| `~/.config/opencode/dcp.jsonc` | DCP plugin config |
| `~/.config/opencode/opencode-notifier.json` | Notifier plugin config |
| `~/.config/opencode/agent-skills/skills/` | 24 engineering skills |
| `~/.agents/skills/` | 31 Firecrawl + web skills |
| `~/.config/ghostty/config` | Ghostty terminal config |

---

## JupyterLab Setup Notes

- **Version:** 4.4.1 in `~/.venvs/jupyter/` (Python 3.11.9)
- **Key packages:** `jupyter-collaboration==4.0.2`, `jupyter-mcp-tools>=0.1.4`, `ipykernel`, `pycrdt`
- **XSRF:** `--ServerApp.disable_check_xsrf=True` is set in the `jlup` alias. This is required for the
  Jupyter MCP to create kernels via the REST API. Safe for localhost-only use; do not expose externally.
- **Token:** Static token read from `~/.jupyter_token`; set `JUPYTER_TOKEN` in `~/.zsh_secrets` to match.

---
