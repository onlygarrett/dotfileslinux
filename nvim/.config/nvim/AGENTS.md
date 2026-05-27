# Agent Guidelines for /home/jee/dotfiles/nvim/.config/nvim

> Scope: This file governs all work in this repository unless superseded by a more specific AGENTS.md deeper in the tree. No other AGENTS.md files currently exist.
> Purpose: Give agentic assistants clear build/run/test commands and code/style expectations.
> Length target: ~150 lines. Keep this file updated when workflows change.

## Quick Start
- Primary stack: Neovim configuration using LazyVim (Lua). Key file: `init.lua` bootstraps `config.lazy` and custom commands.
- Package manager: `lazy.nvim` installed into `vim.fn.stdpath("data")/lazy/lazy.nvim` (see `lua/config/lazy.lua`).
- Formatting: Use `stylua` (`stylua.toml` sets spaces, width 2, column width 120). Respect existing `-- stylua: ignore` pragmas.
- Tests: No automated tests in repo. Validate by opening Neovim and ensuring config loads without errors.
- Git: Avoid committing unless user asks. If you commit, follow existing style (no guidance present).

## Build / Lint / Test Commands
- Install dependencies (one-time): open Neovim and let Lazy bootstrap; ensure `git` available for plugin downloads.
- Format all Lua: `stylua .`
- Format single file: `stylua path/to/file.lua`
- Lint (if available): Prefer `luacheck` if user adds it; none configured currently.
- Run config smoke test: `nvim --headless "+qa"` (verifies startup scriptable). Expect a quick exit if no startup errors.
- Run Lazy health check: `nvim --headless "+Lazy! sync" "+qa"` (sync plugins) then `nvim --headless "+checkhealth" "+qa"` (optional, interactive output).
- Run single plugin-related check: open Neovim and exercise mappings manually; no automated single-test harness exists.

## Repository Layout
- `init.lua`: bootstraps LazyVim, custom PATH tweaks.
- `lua/config/`: core settings (`lazy.lua`, `options.lua`, `remaps.lua`, `commands.lua`, `autocmds.lua`, `functions.lua`, `duplicates.lua`).
- `lua/plugins/`: plugin specs and overrides (LazyVim-compatible).
- `stylua.toml`: formatting rules.
- `lazy-lock.json`, `lazyvim.json`: lock and preset data for LazyVim.

## Coding Style (Lua)
- Formatting: Run `stylua` before delivering changes. Indent 2 spaces, column width 120, spaces not tabs.
- Imports/Requires: Use local aliases where appropriate (`local r = require("config.remaps")`). Group stdlib first, then local modules. Avoid unused requires.
- Tables: Prefer literal tables; keep trailing commas where Lua allows (stylua handles). Use keyed tables for clarity over positional when meaningful.
- Functions: Use `local` functions where scope allows. Keep small helpers in the same file; share via modules under `lua/config` when reused.
- Types/Annotations: Lua 5.1 without strict typing; you may add EmmyLua annotations if helpful but keep concise.
- Naming: Descriptive snake_case for locals and module fields (e.g., `on_attach`, `extract_zip`). Avoid one-letter names unless for indices.
- Strings: Use double quotes consistently (matches repo). Use single quotes only when escaping is simpler.
- Error handling: Prefer `pcall`/`vim.notify` for plugin-dependent code. For external commands (`jobstart`), log exit codes. Avoid hard-failing Neovim startup unless critical.
- Command definitions: Use `vim.api.nvim_create_user_command` with `desc` metadata; keep side effects minimal.
- Autocmds: Define via `vim.api.nvim_create_autocmd`; provide `callback` functions; avoid global leaks.
- Keymaps: Centralize in `config.remaps`; include descriptions. Use `<leader>` mappings consistent with LazyVim conventions.
- Side effects: Avoid heavy work at require-time; prefer lazy setup through Lazy plugin specs or autocmds.
- Notifications/logging: Use `vim.notify` for user-facing messages; respect LazyVim defaults; avoid noisy prints except for debug helpers.
- Platform specifics: PATH is extended for Windows Git (`init.lua`); avoid breaking cross-platform behavior.
- Comments: Keep concise; avoid block banners unless already present. Do not add copyright headers.

## Plugin Specs (LazyVim)
- Location: `lua/plugins/*.lua`; each returns a spec table.
- Defaults: LazyVim base imported via `config.lazy` spec. To add plugins, append entries; to disable, set `enabled=false`.
- Options: Prefer `opts` functions to extend defaults rather than replace. Merge tables using `vim.list_extend` or table operations; avoid deep overwrites unless intended.
- Events: Use `event`/`cmd`/`ft` keys for lazy-loading where possible.
- Keymaps in specs: Provide `desc`; avoid conflicts with core mappings.
- Styling directives: Honor `-- stylua: ignore` when present.

## Testing / Verification Practices
- Minimal check: `nvim --headless "+qa"` after changes to ensure no startup errors.
- Plugin sync (when changing specs): `nvim --headless "+Lazy! sync" "+qa"` to install/update; check for errors in output.
- Targeted repros: Use `nvim --headless -c "lua <lua_code>" +qa` for small snippets if needed.
- No dedicated unit tests; rely on manual validation of mappings/commands.

## Git & Change Management
- Do not commit unless asked. If committing, summarize intent clearly.
- Keep changes scoped; avoid unrelated refactors. Do not modify `lazy-lock.json` unless required for plugin updates; coordinate with user before lockfile churn.
- Provide file/line references in handoff; avoid massive diffs.

## Documentation Updates
- Update this AGENTS.md when workflows change. Keep scope note at top. Maintain ~150 lines by trimming obsolete details.
- Add usage notes for new scripts or commands near relevant sections.

## Security & Safety
- Avoid executing untrusted remote code. For external commands (e.g., unzip), ensure inputs are sanitized. Respect user secrets; do not add telemetry.

## Missing Cursor/Copilot Rules
- No `.cursor/rules/`, `.cursorrules`, or `.github/copilot-instructions.md` found. If added later, include their guidance here.

## Common Pitfalls
- Forgetting to run `stylua` leads to formatting drift.
- Adding heavy logic in top-level plugin specs can slow startup; prefer lazy callbacks.
- Hardcoding platform paths can break non-Windows setups; keep conditionals if adding platform-specific code.
- Leaving debug prints (`print`) in normal paths can spam users; remove before finalizing.

## When In Doubt
- Ask for clarification on desired behaviors before large changes.
- Prefer small, reversible edits; avoid global side effects.
- Validate in headless mode after editing configuration files.

## Single-Test Note
- There is no per-test runner; the closest analog is running a focused headless Neovim invocation that exercises the specific module or command you changed (e.g., `nvim --headless -c "lua require('config.functions').extract_zip('foo.zip')" +qa`). Keep such invocations minimal and reversible.
