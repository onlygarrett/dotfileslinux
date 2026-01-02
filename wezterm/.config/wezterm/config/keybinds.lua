-- keybinds
local wezterm = require("wezterm")
local action = wezterm.action

local mod = {}

-- mod.SUPER = 'ALT'
-- mod.SUPER_REV = 'ALT|CTRL'

local keys = {
	-- Tabs
	{
		key = "t",
		mods = "LEADER",
		action = action.SpawnTab("DefaultDomain"),
	},
	-- {
	-- 	key = "t",
	-- 	mods = "LEADER|SHIFT",
	-- 	action = wezterm.action.SpawnCommandInNewTab({
	-- 		args = { "wsl" },
	-- 		-- this is normally the default, but I'd recommend making it explicit
	-- 		-- when working on windows with WSL and other mux domains.
	-- 		-- This ensures that the command will be run on the wezterm GUI host
	-- 		-- and not in some other domain
	-- 		-- domain = { DomainName = "WSL:Ubuntu" },
	-- 	}),
	-- },
	{ -- Navagating Tabs
		key = "n",
		mods = "LEADER",
		action = action({ ActivateTabRelative = 1 }),
	},
	{
		key = "p",
		mods = "LEADER",
		action = action({ ActivateTabRelative = -1 }),
	},
	-- Panes
	{ -- Making Panes
		key = "\\",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({
			domain = "CurrentPaneDomain",
		}),
	},
	-- { -- Making Panes with wsl
	-- 	key = "|",
	-- 	mods = "LEADER|SHIFT",
	-- 	action = wezterm.action.SplitHorizontal({
	-- 		domain = "CurrentPaneDomain",
	-- 		args = { "wsl" },
	-- 	}),
	-- },
	{
		key = "F3",
		mods = "NONE",
		action = action.ShowLauncher,
	},
	{
		key = "-",
		mods = "LEADER",
		action = action({ SplitVertical = { domain = "CurrentPaneDomain" } }),
	},
	-- { -- Making Panes with wsl
	-- 	key = "_",
	-- 	mods = "LEADER|SHIFT",
	-- 	action = wezterm.action.SplitVertical({
	-- 		domain = "CurrentPaneDomain",
	-- 		args = { "wsl" },
	-- 	}),
	-- },
	{ -- Navagating Panes
		key = "Enter",
		mods = "LEADER",
		action = action.TogglePaneZoomState,
	},
	{ -- Navagating Panes
		key = "LeftArrow",
		mods = "ALT",
		action = action({ ActivatePaneDirection = "Left" }),
	},
	{
		key = "RightArrow",
		mods = "ALT",
		action = action({ ActivatePaneDirection = "Right" }),
	},
	{
		key = "UpArrow",
		mods = "ALT",
		action = action({ ActivatePaneDirection = "Up" }),
	},
	{
		key = "DownArrow",
		mods = "ALT",
		action = action({ ActivatePaneDirection = "Down" }),
	},
	{ -- Cycle through Pane
		key = "n",
		mods = "LEADER|ALT",
		action = action({ ActivatePaneDirection = "Next" }),
	},
	{
		key = "p",
		mods = "LEADER|ALT",
		action = action({ ActivatePaneDirection = "Prev" }),
	},
	{ -- Size the Pane
		key = "h",
		mods = "LEADER|ALT",
		action = action({ AdjustPaneSize = { "Left", 1 } }),
	},
	{
		key = "l",
		mods = "LEADER|ALT",
		action = action({ AdjustPaneSize = { "Right", 1 } }),
	},
	{
		key = "k",
		mods = "LEADER|ALT",
		action = action({ AdjustPaneSize = { "Up", 1 } }),
	},
	{
		key = "j",
		mods = "LEADER|ALT",
		action = action({ AdjustPaneSize = { "Down", 1 } }),
	},
	{ -- Kill Panes
		key = "x",
		mods = "LEADER",
		action = action({ CloseCurrentPane = { confirm = false } }),
	},
	{ key = "+", mods = "CTRL", action = action.IncreaseFontSize },
	{ key = "+", mods = "SHIFT|CTRL", action = action.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = action.DecreaseFontSize },
	{ key = "-", mods = "SHIFT|CTRL", action = action.DecreaseFontSize },

	{ key = "PageUp", mods = "CTRL", action = action.ScrollByPage(-1) },
	{ key = "PageDown", mods = "CTRL", action = action.ScrollByPage(1) },
	{ key = "P", mods = "SHIFT|CTRL", action = action.ActivateCommandPalette },
	{ key = "V", mods = "CTRL", action = action.PasteFrom("Clipboard") },
}

local mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = action.OpenLinkAtMouseCursor,
	},
}

return {
	disable_default_key_bindings = true,
	-- disable_default_mouse_bindings = true,
	leader = { key = "Space", mods = "CTRL" },
	keys = keys,
	mouse_bindings = mouse_bindings,
}
