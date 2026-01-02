-- https://github.com/nvim-treesitter/nvim-treesitter
local dir_parser = os.getenv("HOME") .. "/.vim/parsers"
vim.opt.runtimepath:append(dir_parser)

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"lua",
		"vim",
		"vimdoc",
		"query",
		"markdown",
		"markdown_inline",
		"comment",
		"diff",
		"asm",
		"angular",
		"bash",
		"c",
		"css",
		"dockerfile",
		"go",
		"gomod",
		"gosum",
		"gitattributes",
		"gitcommit",
		"gitignore",
		"git_config",
		"hcl",
		"html",
		"java",
		"javascript",
		"json",
		"kdl",
		"latex",
		"nix",
		"scss",
		"ssh_config",
		"sql",
		"sway",
		"r",
		"rust",
		"terraform",
		"toml",
		"typescript",
		"yaml",
		"xml",
		"zig",
		"ziggy",
	},
	sync_install = false,
	auto_install = true,
	parser_install_dir = dir_parser,
	highlight = {
		enable = true,
		disable = function(lang, buf)
			if lang == "html" or lang == "css" or lang == "js" then
				local max_size = 256 * 1024
				---@diagnostic disable-next-line: undefined-field
				local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max_size then
					return true
				end
			end
			return false
		end,
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true,
	},
})
