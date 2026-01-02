-- https://github.com/kylechui/nvim-surround
require("nvim-surround").setup({
	surrounds = {
		["("] = false,
		["["] = false,
		["{"] = false,
	},
	aliases = {
		["("] = ")",
		["["] = "]",
		["{"] = "}",
	},
})
