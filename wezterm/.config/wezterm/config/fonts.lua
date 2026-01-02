local wezterm = require("wezterm")

local font = "Iosevka Term"
-- local font = "CaskaydiaCove Nerd Font Mono"
local font_size = 14
local cell_width = 0.9

return {
	font = wezterm.font(font),
	font_size = font_size,
	cell_width = cell_width,
}
