-- https://github.com/nvim-treesitter/nvim-treesitter
local dir_parser = os.getenv("HOME") .. "/.vim/parsers"
vim.opt.runtimepath:append(dir_parser)

local max_size = 256 * 1024
local function too_big(buf)
	---@diagnostic disable-next-line: undefined-field
	local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
	return ok and stats and stats.size > max_size
end

local size_limited = {
	html = true,
	css = true,
	javascript = true,
	json = true,
	xml = true,
	yaml = true,
}

require("nvim-treesitter").setup({
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
		"astro",
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
		"javascript",
		"json",
		"kdl",
		"nix",
		"scss",
		"ssh_config",
		"sql",
		"sway",
		"python",
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
			if size_limited[lang] then
				return too_big(buf)
			end
			return false
		end,
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = true,
		disable = function(lang, buf)
			if lang == "html" then
				return true
			end
			return too_big(buf)
		end,
	},
})
