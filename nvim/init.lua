vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.clipboard = "unnamedplus"
vim.opt.wildignore:append({
	"*/node_modules/*",
	"*/target/*",
	"*/dist/*",
	"*/.angular/*",
	"*/.git/*",
	"*.min.css",
	"*.min.js",
})

-- Filetype
local function set_filetype_c()
	vim.bo.filetype = "c"
end
local function set_filetype_conf()
	vim.bo.filetype = "conf"
end
local function set_filetype_json()
	vim.bo.filetype = "json"
end
local function set_filetype_dotenv()
	vim.bo.filetype = "dotenv"
end

vim.api.nvim_create_augroup("FiletypeConfig", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.h" },
	callback = set_filetype_c,
	group = "FiletypeConfig",
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*/config", "*/conf" },
	callback = set_filetype_conf,
	group = "FiletypeConfig",
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*/.env*" },
	callback = set_filetype_dotenv,
	group = "FiletypeConfig",
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { ".firebaserc" },
	callback = set_filetype_json,
	group = "FiletypeConfig",
})

-- Number
vim.opt.nu = true
vim.opt.cursorline = true
vim.opt.relativenumber = true

-- Tab indent
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
--
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "yaml", "nix" },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.shiftwidth = 2
	end,
})
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "flake.lock",
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		vim.opt_local.shiftwidth = 2
	end,
})
vim.opt.smartindent = true
vim.opt.showmode = false
vim.opt.wrap = false
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undo"
vim.opt.undofile = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.cmdheight = 0
vim.opt.showcmd = false
vim.opt.scrolloff = 10
--
local options = { noremap = true, silent = true }
vim.g.mapleader = " "
-- Noop
vim.keymap.set("n", "q", "<Nop>", options)
vim.keymap.set("v", "q", "<Nop>", options)
vim.keymap.set("n", "Q", "<Nop>", options)
-- Hlsearch
vim.keymap.set("n", "<leader>n", ":noh<CR>", options)
vim.keymap.set({ "n", "v" }, "<leader>h", "^", options)
vim.keymap.set({ "n", "v" }, "<leader>l", "$", options)
-- Explorer
vim.keymap.set("n", "<leader>ee", ":NvimTreeToggle<CR>", options)
vim.keymap.set("n", "<leader>ef", ":NvimTreeFocus<CR>", options)
vim.keymap.set("n", "<leader>ec", ":NvimTreeCollapse<CR>", options)
vim.keymap.set("n", "<leader>er", ":NvimTreeRefresh<CR>", options)
-- Yank/Paste/Change/Delete
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
-- d
vim.keymap.set("n", "d", '"_d', { noremap = true })
vim.keymap.set("n", "dd", '"_dd', { noremap = true })
vim.keymap.set("n", "D", '"_D', { noremap = true })
vim.keymap.set("x", "d", '"_d', { noremap = true })
vim.keymap.set("n", "da", '"_da', { noremap = true })
vim.keymap.set("n", "di", '"_di', { noremap = true })
vim.keymap.set("n", "dw", '"_dw', { noremap = true })
vim.keymap.set("n", "D", '"_D', { noremap = true })
-- c
vim.keymap.set("n", "c", '"_c', { noremap = true })
vim.keymap.set("n", "C", '"_C', { noremap = true })
vim.keymap.set("x", "c", '"_c', { noremap = true })
vim.keymap.set("n", "ca", '"_ca', { noremap = true })
vim.keymap.set("n", "ci", '"_ci', { noremap = true })
vim.keymap.set("n", "cw", '"_cw', { noremap = true })
vim.keymap.set("n", "C", '"_C', { noremap = true })
--
vim.keymap.set("n", "d<Left>", '"_dh', options)
vim.keymap.set("n", "d<Right>", '"_dl', options)
vim.keymap.set("n", "d<Up>", '"_d<Up>', options)
vim.keymap.set("n", "d<Down>", '"_d<Down>', options)
-- Tab
vim.opt.showtabline = 2
vim.keymap.set("n", "<leader>ta", ":$tabnew<CR>", { noremap = true })
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { noremap = true })
vim.keymap.set("n", "<leader>to", ":tabonly<CR>", { noremap = true })
vim.keymap.set("n", "<leader>tn", ":tabn<CR>", { noremap = true })
vim.keymap.set("n", "<leader>tp", ":tabp<CR>", { noremap = true })
vim.keymap.set("n", "<leader>1", "1gt", options)
vim.keymap.set("n", "<leader>2", "2gt", options)
vim.keymap.set("n", "<leader>3", "3gt", options)
vim.keymap.set("n", "<leader>4", "4gt", options)
vim.keymap.set("n", "<leader>5", "5gt", options)
vim.keymap.set("n", "<leader>6", "6gt", options)
vim.keymap.set("n", "<leader>7", "7gt", options)
vim.keymap.set("n", "<leader>8", "8gt", options)
vim.keymap.set("n", "<leader>9", "9gt", options)
-- Definiton
--Ctrl ] and Ctrl o
-- Diagnostic
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end)
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end)
-- CTRL
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "<C-z>", "u", options)
vim.keymap.set({ "i", "v" }, "<C-z>", "<Nop>")
vim.keymap.set("n", "<C-y>", "<C-r>", options)
vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==", { silent = true })
vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", { silent = true })
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", { silent = true })
-- Markdown preview
function ToggleMarkdownPreview()
	local is_running = vim.g.markdown_preview_running or false
	if is_running then
		vim.cmd("MarkdownPreviewStop")
		vim.g.markdown_preview_running = false
	else
		vim.cmd("MarkdownPreview")
		vim.g.markdown_preview_running = true
	end
end
vim.keymap.set("n", "<leader>mp", ToggleMarkdownPreview, options)
-- Undotree
vim.keymap.set("n", "<leader><F1>", vim.cmd.UndotreeToggle)
vim.api.nvim_create_autocmd("VimLeave", {
	pattern = "*",
	command = "set guicursor=a:ver25-Cursor/lCursor",
})
-- Wrap
function WrapWord(symbol1, symbol2)
	local word = vim.fn.expand("<cword>")
	local cmd = string.format("normal ciw%s%s%s", symbol1, word, symbol2)
	vim.cmd(cmd)
end
vim.keymap.set("n", "<leader>()", ":lua WrapWord('(', ')')<CR>", options)
vim.keymap.set("n", "<leader>[]", ":lua WrapWord('[', ']')<CR>", options)
vim.keymap.set("n", "<leader>{}", ":lua WrapWord('{', '}')<CR>", options)
vim.keymap.set("n", "<leader>'w", ':lua WrapWord("\'", "\'")<CR>', options)
vim.keymap.set("n", '<leader>"w', ":lua WrapWord('\"', '\"')<CR>", options)
vim.keymap.set("n", "<leader><>", ":lua WrapWord('<', '>')<CR>", options)
-- Telescope cmd
vim.keymap.set("n", "<leader><leader>", ":Telescope cmdline<CR>", { noremap = true, desc = "Cmd" })
-- Lazygit
vim.keymap.set("n", "<leader>gg", ":LazyGit<CR>", options)
-- Nui
vim.keymap.set("n", ":", "<cmd>FineCmdline<CR>", { noremap = true })
vim.keymap.set("n", "<leader>ss", ":SearchBoxIncSearch<CR>")
vim.keymap.set("x", "<leader>ss", ":SearchBoxIncSearch visual_mode=true<CR>")
