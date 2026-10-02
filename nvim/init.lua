vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.clipboard = "unnamedplus"
-- Suppresses the built-in intro, which the startup screen at the bottom replaces.
vim.opt.shortmess:append("I")
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
vim.api.nvim_create_augroup("FiletypeConfig", { clear = true })
local ft_map = {
	{ pattern = { "*.h" }, filetype = "c" },
	{ pattern = { "*/config", "*/conf" }, filetype = "conf" },
	{ pattern = { "*/.env*" }, filetype = "dotenv" },
	{ pattern = { ".firebaserc" }, filetype = "json" },
}
for _, m in ipairs(ft_map) do
	vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
		pattern = m.pattern,
		callback = function()
			vim.bo.filetype = m.filetype
		end,
		group = "FiletypeConfig",
	})
end

-- Number
vim.opt.nu = true
vim.opt.cursorline = true
vim.opt.relativenumber = true

-- Tab indent
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
-- Markdown ftplugin forces expandtab unless its recommended style is off.
vim.g.markdown_recommended_style = 0
--
local function indent_2()
	vim.opt_local.tabstop = 2
	vim.opt_local.softtabstop = 2
	vim.opt_local.shiftwidth = 2
	vim.opt_local.expandtab = true
end
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "nix", "toml", "yaml" },
	callback = indent_2,
})
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "flake.lock",
	callback = indent_2,
})
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermClose", "TermLeave" }, {
	command = "checktime",
})
vim.opt.smartindent = true
vim.opt.showmode = false
vim.opt.wrap = false
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.autoread = true
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
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
-- c
vim.keymap.set("n", "c", '"_c', { noremap = true })
vim.keymap.set("n", "C", '"_C', { noremap = true })
vim.keymap.set("x", "c", '"_c', { noremap = true })
vim.keymap.set("n", "ca", '"_ca', { noremap = true })
vim.keymap.set("n", "ci", '"_ci', { noremap = true })
vim.keymap.set("n", "cw", '"_cw', { noremap = true })
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
vim.keymap.set("i", "<C-z>", "<Esc>u")
vim.keymap.set("v", "<C-z>", "<Nop>")
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
-- Startup screen
-- Neovim's intro is hardcoded in C and cannot be edited, only suppressed
-- (shortmess "I" at the top) and redrawn.
-- figlet -f small nvim
local startup_art = {
	"         _",
	" _ ___ _(_)_ __",
	"| ' \\ V / | '  \\",
	"|_||_\\_/|_|_|_|_|",
}

local startup_menu = {
	{ "h", "hunt down a file" },
	{ "j", "jump to any word in the tree" },
	{ "k", "keep tabs on open buffers" },
	{ "l", "launch a blank buffer" },
}

local startup_actions = {
	h = "Telescope find_files",
	j = "lua require('telescope').extensions.live_grep_args.live_grep_args()",
	k = "Telescope buffers",
	l = "enew",
}

-- tokei only honours .gitignore, so vendored and minified trees that are
-- committed still need excluding by hand.
local startup_tokei_exclude = {
	".agents",
	".angular",
	".astro",
	".backup",
	".claude",
	".codegraph",
	".codex",
	".env",
	".env.*",
	".firebase",
	".git",
	".github",
	"dist",
	"node_modules",
	"out",
	"target",
	"tmp",
	"vendor",
	"*_test.go",
	"*.bak",
	"*.log",
	"*.min.*",
	"note.txt",
}

-- Both filled in asynchronously; the screen is redrawn as each one lands.
local startup_stat = { loc = "", git = "" }

local function startup_render(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	local win = vim.fn.bufwinid(buf)
	if win == -1 then
		return
	end

	local menu = {}
	for _, item in ipairs(startup_menu) do
		table.insert(menu, string.format("%s   %s", item[1], item[2]))
	end

	local groups = { startup_art, menu }
	for _, stat in ipairs({ startup_stat.loc, startup_stat.git }) do
		if stat ~= "" then
			table.insert(groups, { stat })
		end
	end
	table.insert(groups, { "NVIM v" .. tostring(vim.version()) })

	local rows = #groups - 1
	for _, group in ipairs(groups) do
		rows = rows + #group
	end

	-- Window metrics, not vim.o.lines/columns: those count the cmdline and
	-- statusline, which pushes the block above the true middle.
	local height = vim.api.nvim_win_get_height(win)
	local width = vim.api.nvim_win_get_width(win)

	local lines = {}
	for _ = 1, math.max(0, math.floor((height - rows) / 2)) do
		table.insert(lines, "")
	end
	-- One shared offset for every group, so the art keeps its shape and the menu,
	-- stats and version all start on the same left edge.
	local block = 0
	for _, group in ipairs(groups) do
		for _, line in ipairs(group) do
			block = math.max(block, vim.fn.strdisplaywidth(line))
		end
	end
	local left = string.rep(" ", math.max(0, math.floor((width - block) / 2)))

	for i, group in ipairs(groups) do
		for _, line in ipairs(group) do
			table.insert(lines, left .. line)
		end
		if i < #groups then
			table.insert(lines, "")
		end
	end

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].modified = false
end

local function startup_count_loc(buf)
	if vim.fn.executable("tokei") ~= 1 then
		startup_stat.loc = "tokei not installed"
		return
	end
	startup_stat.loc = "Counting lines of code..."

	local cmd = { "tokei", "--output", "json" }
	for _, pattern in ipairs(startup_tokei_exclude) do
		table.insert(cmd, "--exclude")
		table.insert(cmd, pattern)
	end

	-- tokei walks the whole tree, so the count lands late. The callback runs in a
	-- fast event context, hence the schedule before touching the buffer.
	vim.system(cmd, { text = true }, function(out)
		local text = "Line count unavailable"
		if out.code == 0 then
			local ok, data = pcall(vim.json.decode, out.stdout)
			if ok and data.Total and data.Total.code then
				text = string.format("%d lines of code in this tree", data.Total.code)
			end
		end
		startup_stat.loc = text
		vim.schedule(function()
			startup_render(buf)
		end)
	end)
end

local function startup_count_git(buf)
	if vim.fn.executable("git") ~= 1 then
		startup_stat.git = "Git not installed"
		return
	end
	vim.system({ "git", "status", "--porcelain" }, { text = true }, function(out)
		-- A non-zero exit here means there is no repository above the cwd.
		local text = "Not a git repository"
		if out.code == 0 then
			local count = 0
			for line in out.stdout:gmatch("[^\n]+") do
				-- Column two is the worktree status; anything but a space means the
				-- change is unstaged. Untracked files arrive as "??".
				if line:sub(2, 2) ~= " " then
					count = count + 1
				end
			end
			if count == 0 then
				text = "Working tree clean"
			else
				text = string.format("%d unstaged change%s", count, count == 1 and "" or "s")
			end
		end
		startup_stat.git = text
		vim.schedule(function()
			startup_render(buf)
		end)
	end)
end

vim.api.nvim_create_autocmd("VimEnter", {
	group = vim.api.nvim_create_augroup("StartupScreen", { clear = true }),
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		-- Bare `nvim` only: no file argument, no piped stdin, nothing typed yet.
		if vim.fn.argc() > 0 or vim.api.nvim_buf_get_name(buf) ~= "" then
			return
		end
		if vim.api.nvim_buf_line_count(buf) > 1 then
			return
		end

		startup_count_loc(buf)
		startup_count_git(buf)
		startup_render(buf)

		vim.bo[buf].buftype = "nofile"
		vim.bo[buf].bufhidden = "wipe"
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.cursorline = false
		vim.opt_local.fillchars = "eob: "

		for key, action in pairs(startup_actions) do
			vim.keymap.set("n", key, "<cmd>" .. action .. "<CR>", { buffer = buf, silent = true })
		end
	end,
})
