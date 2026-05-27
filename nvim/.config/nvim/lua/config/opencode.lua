-- OpenCode Neovim Integration - Quick Reference
--
-- This file serves as documentation for your OpenCode setup.
-- The actual configuration is in lua/plugins/opencode.lua

---@class OpenCodeQuickRef
local M = {}

-- Core Keymaps
-- ============
--
-- Interaction:
--   <Leader>oa  - Ask OpenCode with @this context (visual selection or cursor)
--   <Leader>oA  - Ask OpenCode without context
--   <Leader>ox  - Open selection menu (prompts, commands, server controls)
--
-- Operator Mode (Vim-native):
--   go          - Start operator to add range to OpenCode (e.g., goip = add paragraph)
--   goo         - Add current line to OpenCode
--
-- Terminal Control:
--   <Leader>oc  - Toggle OpenCode terminal (works in normal and terminal mode)
--   <Leader>os  - Stop OpenCode server
--
-- Navigation (scroll OpenCode from Neovim):
--   <Leader>ou  - Scroll OpenCode up
--   <Leader>od  - Scroll OpenCode down
--   <Leader>og  - Go to first OpenCode message
--   <Leader>oG  - Go to last OpenCode message
--
-- Session Management:
--   <Leader>ol  - List OpenCode sessions
--   <Leader>on  - Create new OpenCode session
--   <Leader>oi  - Interrupt OpenCode (stop current response)

-- Available Contexts
-- ==================
-- These placeholders can be used in prompts:
--
--   @this         - Current selection/range or cursor position
--   @buffer       - Current buffer
--   @buffers      - All open buffers
--   @visible      - Visible text in current window
--   @diagnostics  - Current buffer diagnostics
--   @quickfix     - Quickfix list
--   @diff         - Git diff
--   @marks        - Global marks
--   @grapple      - Grapple.nvim tags (if installed)

-- Built-in Prompts
-- ================
-- Access via <Leader>ox, then select from:
--
-- Code Quality:
--   review      - Review @this for correctness, readability, best practices
--   optimize    - Optimize @this for performance and readability
--   document    - Add comprehensive documentation to @this
--
-- Testing:
--   test        - Write comprehensive tests for @this
--
-- Debugging:
--   explain     - Explain @this and its context in detail
--   diagnostics - Explain diagnostics in current buffer
--   fix         - Fix diagnostics in current buffer
--
-- Git:
--   diff        - Review git diff for correctness and readability
--   commit      - Generate commit message from git diff
--
-- Refactoring:
--   refactor    - Refactor @this to improve quality and maintainability
--   implement   - Implement the code described in @this

-- Snacks.nvim Integration
-- =======================
-- When using the picker (<Leader>ox) or input (<Leader>oa):
--   - LSP-based completions for contexts (@this, @buffer, etc.)
--   - Syntax highlighting in input
--   - Preview of prompts in picker
--   - <Alt-a> in picker to send selection to OpenCode

-- Event Handlers
-- ==============
-- The plugin automatically:
--   - Reloads files when OpenCode edits them
--   - Shows notifications when OpenCode finishes responding
--   - Handles permission requests
--   - Hides OpenCode terminal from buffer list
--   - Auto-selects last session on server connect
--   - Stops OpenCode server on Neovim exit

-- Statusline Integration
-- ======================
-- OpenCode status appears in lualine_x (before encoding/filetype)
-- Shows current OpenCode state when active

-- Experimental Features
-- =====================
-- To enable experimental LSP support, edit lua/plugins/opencode.lua:
--   vim.g.opencode_opts.lsp.enabled = true
--
-- This provides:
--   - Hover (K) for AI explanations of symbols
--   - Code actions for diagnostics
--   - Integrated into standard LSP workflow

-- Tips
-- ====
-- 1. Use visual mode + <Leader>oa to ask about specific code
-- 2. Use go{motion} for precise range selection (e.g., goip for paragraph)
-- 3. Remember to save files before asking OpenCode to read them
-- 4. Use <Leader>ox to discover all available prompts and commands
-- 5. The @diagnostics context is great for quick fixes
-- 6. Create your own prompts in lua/plugins/opencode.lua

return M
