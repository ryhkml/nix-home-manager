-- https://github.com/stevearc/conform.nvim
require("conform").setup({
	formatters_by_ft = {
		asm = { "asmfmt" },
		c = { "clang-format" },
		css = { "prettier" },
		fish = { "fish_indent" },
		go = { "gofmt" },
		hcl = function(bufnr)
			local filename = vim.api.nvim_buf_get_name(bufnr)
			if filename:match("%.pkr.hcl$") or filename:match("%.pkrvars.hcl$") then
				return { "packer_fmt" }
			end
			return { "hcl" }
		end,
		html = { "prettier" },
		java = { "astyle" },
		javascript = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		less = { "prettier" },
		lua = { "stylua" },
		nix = { "nixfmt" },
		r = { "styler" },
		rust = { "rustfmt" },
		scss = { "prettier" },
		sh = { "beautysh" },
		tex = { "tex-fmt" },
		tf = { "terraform_fmt" },
		toml = { "taplo" },
		typescript = { "prettier" },
		yaml = { "yamlfmt" },
		zig = { "zigfmt" },
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
		astyle = {
			prepend_args = {
				"--style=java",
				"-t4",
				"--add-braces",
			},
		},
		beautysh = {
			prepend_args = {
				"--indent-size",
				"4",
				"--tab",
			},
		},
		nixfmt = {
			prepend_args = {
				"--width=100",
			},
		},
		prettier = {
			prepend_args = {
				"--print-width",
				"100",
				"--use-tabs",
				"--tab-width",
				"4",
				"--trailing-comma",
				"none",
				"--embedded-language-formatting",
				"auto",
			},
		},
		["tex-fmt"] = {
			prepend_args = {
				"--wraplen",
				"100",
				"--usetabs",
				"--nowrap",
			},
		},
	},
})
