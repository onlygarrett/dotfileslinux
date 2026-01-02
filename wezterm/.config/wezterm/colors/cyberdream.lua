local colorscheme = {
	foreground = "#ffffff",
	background = "#000000",

	cursor_bg = "#b2b2b2",
	cursor_fg = "#16181a",
	cursor_border = "#ffffff",

	selection_fg = "#ffffff",
	selection_bg = "#3c4048",

	scrollbar_thumb = "#16181a",
	split = "#ffffff",
	ansi = { "#16181a", "#ff6e5e", "#5eff6c", "#f1ff5e", "#5ea1ff", "#bd5eff", "#5ef1ff", "#ffffff" },
	brights = { "#3c4048", "#ff6e5e", "#5eff6c", "#f1ff5e", "#5ea1ff", "#bd5eff", "#5ef1ff", "#ffffff" },
	indexed = { [16] = "#ffbd5e", [17] = "#ff6e5e" },

	tab_bar = {
		background = "#000000",
		active_tab = {
			bg_color = "#46326b",
			fg_color = "#000000",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#000000",
			fg_color = "#46326b",
		},
		new_tab = {
			bg_color = "#141414",
			fg_color = "#46326b",
		},
	},
}

return colorscheme
