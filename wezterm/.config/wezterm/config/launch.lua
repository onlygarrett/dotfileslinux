local wezterm = require("wezterm")
-- local mux = wezterm.mux
-- wezterm.on("gui-startup", function()
--   local tab, pane,window = mux.spawn_window()
--   window:gui_window():maximize()
-- end)
local options = {
	default_prog = {},
	launch_menu = {},
}

-- options.default_prog = { "wsl" }
-- options.default_prog = { "pwsh" }
options.default_prog = { "/usr/bin/zsh" }

options.launch_menu = {
	{ label = " Zsh", args = { "/usr/bin/zsh" }, domain = "DefaultDomain" },
	-- { label = " PowerShell v7", args = { "pwsh" }, domain = "DefaultDomain" },
	-- { label = " WSL", args = { "wsl" }, domain = { DomainName = "WSL" } },
	-- { label = " Cmd", args = { "cmd" }, domain = "DefaultDomain" },
	-- {
	-- 	label = " GitBash",
	-- 	args = { "C:\\Program Files\\Git\\git-bash.exe" },
	-- 	domain = "DefaultDomain",
	-- },
}

return options
