-- https://github.com/VonHeikemen/fine-cmdline.nvim
require("fine-cmdline").setup({
	popup = {
		position = "50%",
		size = {
			width = "20%",
		},
		border = {
			style = "single",
			text = {
				top = " Command ",
				top_align = "center",
			},
			padding = "0",
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
		},
	},
})
