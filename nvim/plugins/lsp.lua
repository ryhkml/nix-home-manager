-- https://github.com/hrsh7th/cmp-nvim-lsp
vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local opts = { buffer = event.buf, silent = true }
		vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
		vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
		vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
		vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
		vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
		vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
		vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
		vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
		vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<CR>", opts)
		vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
	end,
})

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
-- ASM
vim.lsp.enable("asm_lsp")
-- Bash
vim.lsp.enable("bashls")
-- C
vim.lsp.enable("clangd")
-- CSS
vim.lsp.config("cssls", {
	capabilities = capabilities,
})
vim.lsp.enable("cssls")
-- Dockerfile
vim.lsp.config("dockerls", {
	settings = {
		docker = {
			languageserver = {
				formatter = {
					ignoreMultilineInstructions = true,
				},
			},
		},
	},
})
vim.lsp.enable("dockerls")
-- HTML
vim.lsp.config("html", {
	capabilities = capabilities,
})
vim.lsp.enable("html")
-- HTMX
--vim.lsp.enable("htmx")
-- Go
vim.lsp.enable("gopls")
-- Java
--vim.lsp.enable("jdtls")
-- JSON
local json_schemas = require("schemastore").json.schemas({
	select = {
		"angular.json",
		"Firebase",
		"package.json",
		"tsconfig.json",
	},
})
table.insert(json_schemas, {
	name = "OpenAPI 3.0",
	description = "OpenAPI 3.0 Specification",
	fileMatch = { "**/openapi/*.json", "openapi.json" },
	url = "https://spec.openapis.org/oas/3.0/schema/2021-09-28",
})
vim.lsp.config("jsonls", {
	settings = {
		json = {
			schemas = json_schemas,
			validate = {
				enable = true,
			},
		},
	},
})
vim.lsp.enable("jsonls")
-- LaTeX
vim.lsp.enable("texlab")
-- Lua
vim.lsp.enable("stylua")
vim.lsp.config("lua_ls", {
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.fn.stdpath("config")
				and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
			then
				return
			end
		end
		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				version = "LuaJIT",
				path = {
					"lua/?.lua",
					"lua/?/init.lua",
				},
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
				},
			},
		})
	end,
	settings = {
		Lua = {},
	},
})
vim.lsp.enable("lua_ls")
-- Nix
vim.lsp.config("nil_ls", {
	settings = {
		["nil"] = {
			formatting = {
				command = { "nixfmt" },
			},
		},
	},
})
vim.lsp.enable("nil_ls")
-- R
vim.lsp.enable("r_language_server")
-- Rust
vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			diagnostics = {
				enable = false,
			},
		},
	},
})
vim.lsp.enable("rust_analyzer")
-- Tailwindcss
vim.lsp.enable("tailwindcss")
-- Terraform
vim.lsp.enable("terraformls")
-- Typescript
vim.lsp.enable("ts_ls")
-- YAML
vim.lsp.config("yamlls", {
	settings = {
		yaml = {
			schemas = {
				["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/*-compose.{yaml,yml}",
				["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/*-compose-*.{yaml,yml}",
			},
		},
	},
})
vim.lsp.enable("yamlls")
-- Zig
vim.lsp.enable("zls")
-- Disable log
vim.lsp.set_log_level("off")
