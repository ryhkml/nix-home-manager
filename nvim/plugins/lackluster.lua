-- https://github.com/slugbyte/lackluster.nvim
local lackluster = require("lackluster")
lackluster.setup({
	tweak_color = {
		lack = "default",
		luster = "default",
		orange = "#d46b08",
		yellow = "#d4b106",
		green = "#389e0d",
		blue = "#096dd9",
		red = "#cf1322",
	},
	tweak_background = {
		normal = "#000000",
		popup = "#191919",
		menu = "#000000",
		telescope = "#000000",
	},
})

vim.cmd.colorscheme("lackluster")
