-- https://github.com/stevearc/conform.nvim
local prettier_formatter = require("conform.formatters.prettier")

local function prettier_args(_, ctx)
	local args = {
		"--print-width",
		"100",
		"--use-tabs",
		"--tab-width",
		"4",
		"--trailing-comma",
		"none",
		"--embedded-language-formatting",
		"auto",
	}
	local fname = vim.fn.fnamemodify(ctx.filename, ":t")
	if fname == ".firebaserc" then
		table.insert(args, "--parser")
		table.insert(args, "json")
	end
	return args
end

local function prettier_plugins_args(self, ctx)
	local args = prettier_args(self, ctx)
	return vim.list_extend(args, prettier_formatter.args(self, ctx) or {})
end

local function prettier_plugins_range_args(self, ctx)
	local args = prettier_args(self, ctx)
	return vim.list_extend(args, prettier_formatter.range_args(self, ctx) or {})
end

require("conform").setup({
	formatters_by_ft = {
		astro = { "prettier_plugins" },
		asm = { "asmfmt" },
		c = { "clang-format" },
		css = { "prettier" },
		fish = { "fish_indent" },
		go = { "gofmt" },
		hcl = { "hcl" },
		html = { "prettier" },
		javascript = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		less = { "prettier" },
		lua = { "stylua" },
		markdown = { "prettier" },
		nginx = { "nginxfmt" },
		nix = { "nixfmt" },
		python = { "isort", "black" },
		rust = { "rustfmt" },
		scss = { "prettier" },
		sh = { "shfmt" },
		svelte = { "prettier_plugins" },
		toml = { "taplo" },
		typescript = { "prettier" },
		yaml = { "yamlfmt" },
		["_"] = { "trim_whitespace" },
	},
	default_format_opts = {
		lsp_format = "fallback",
	},
	format_on_save = {
		lsp_format = "fallback",
		timeout_ms = 1000,
	},
	log_level = vim.log.levels.ERROR,
	notify_on_error = true,
	notify_no_formatters = false,
	-- Custom formatters and overrides for built-in formatters
	formatters = {
		nixfmt = {
			prepend_args = {
				"--width=100",
			},
		},
		prettier_plugins = {
			command = "prettier-with-plugins",
			args = prettier_plugins_args,
			range_args = prettier_plugins_range_args,
			cwd = prettier_formatter.cwd,
		},
		prettier = {
			prepend_args = prettier_args,
		},
		shfmt = {
			args = {
				"-i",
				"0",
				"-ci",
				"-filename",
				"$FILENAME",
			},
		},
	},
})
