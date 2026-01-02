-- https://github.com/shellRaining/hlchunk.nvim
require("hlchunk").setup({
	chunk = {
		enable = true,
		use_treesitter = false,
		chars = {
			horizontal_line = "─",
			vertical_line = "│",
			left_top = "╭",
			left_bottom = "╰",
			right_arrow = ">",
		},
		max_file_size = 2 * 1024 * 1024,
		style = "#708090",
		duration = 250,
		delay = 500,
		exclude_filetypes = {
			aerial = true,
			dashboard = true,
			Dockerfile = true,
			conf = true,
			txt = true,
		},
	},
	indent = {
		enable = true,
		chars = {
			"",
		},
		filter_list = {
			function(v)
				return v.level ~= 1
			end,
		},
		exclude_filetypes = {
			aerial = true,
			dashboard = true,
		},
	},
})
