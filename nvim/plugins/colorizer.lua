-- https://github.com/nvchad/nvim-colorizer.lua
require("colorizer").setup({
	filetypes = {
		"html",
		"css",
		"scss",
		"sass",
		"less",
		"javascript",
		"typescript",
	},
	user_default_options = {
		RGB = true,
		RRGGBB = true,
		names = false,
		RRGGBBAA = true,
		AARRGGBB = true,
		rgb_fn = false,
		hsl_fn = false,
		css = false,
		css_fn = false,
		mode = "background",
		tailwind = false,
		sass = { enable = false, parsers = { "css" } },
		virtualtext = "^",
		always_update = false,
	},
	buftypes = {},
})
