local wezterm = require("wezterm")
local colors = require("colors.cyberdream")
local fonts = require("config.fonts")
local gpu_adapters = require("utils.gpu_adapters")

return {
	term = "xterm-256color",
	max_fps = 60,
	front_end = "OpenGL",
	webgpu_power_preference = "HighPerformance",
	webgpu_preferred_adapter = gpu_adapters:pick_best(),

	-- color scheme
	colors = colors,
	font = fonts.font,
	line_height = 1,
	font_size = fonts.font_size,
	bold_brightens_ansi_colors = true,

	window_background_opacity = 0.50,
	kde_window_background_blur = true,
	text_background_opacity = 1,
	-- background
	-- win32_system_backdrop = "Acrylic",
	-- window_background_gradient = {
	-- 	colors = { "#1D261B", "#261A25" },
	-- 	-- Specifices a Linear gradient starting in the top left corner.
	-- 	orientation = { Linear = { angle = -45.0 } },
	-- },
	-- background = {
	-- 	{
	-- 		source = { File = wezterm.config_dir .. "/assets/cybercar.png" },
	-- 	},
	-- 	{
	-- 		source = { Color = "#1A1B26" },
	-- 		height = "100%",
	-- 		width = "100%",
	-- 		opacity = 0.95,
	-- 	},
	-- },
	--
	-- scrollbar
	enable_scroll_bar = true,
	min_scroll_bar_height = "3cell",
	-- tab bar
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = true,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = false,
	tab_max_width = 25,
	show_tab_index_in_tab_bar = true,
	switch_to_last_active_tab_when_closing_tab = true,

	-- cursor
	-- default_cursor_style = "BlinkingBlock",
	-- cursor_blink_ease_in = "Constant",
	-- cursor_blink_ease_out = "Constant",
	-- cursor_blink_rate = 200,

	-- window
	-- adjust_window_size_when_changing_font_size = false,
	-- window_decorations = "INTEGRATED_BUTTONS|RESIZE",
	-- integrated_title_button_style = "Windows",
	-- integrated_title_button_color = "auto",
	-- integrated_title_button_alignment = "Right",
	-- initial_cols = 120,
	-- initial_rows = 24,
	-- window_padding = {
	-- 	left = 0,
	-- 	right = 0,
	-- 	top = 0,
	-- 	bottom = 0,
	-- },
	window_close_confirmation = "AlwaysPrompt",
	-- window_frame = {
	-- 	active_titlebar_bg = "#2b2042",
	-- 	inactive_titlebar_bg = "#0F2536",
	-- 	font = fonts.font,
	-- 	font_size = 12,
	-- },
	-- inactive_pane_hsb = { saturation = 0.7, brightness = 0.1 },
}
