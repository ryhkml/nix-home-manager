-- https://github.com/slugbyte/lackluster.nvim
local lackluster = require("lackluster")

-- Sway's window border (#526596), lightened to clear 4.5:1 on the background.
-- Applied to the string groups only, never to the `lack` palette slot -- that
-- slot feeds dozens of unrelated groups and tinting it turns half the editor blue.
local blue = "#667db7"
-- Lighter tint of the same hue for escapes: visible without adding a second color.
local blue_bright = "#9fb0d8"

lackluster.setup({
	tweak_color = {
		lack = "default",
		luster = "default",
		orange = "#d46b08",
		yellow = "#d4b106",
		green = "#389e0d",
		blue = "default",
		-- red-5, not red-7: #cf1322 is 3.51:1. Matches normal.red in Ghostty.
		red = "#ff4d4f",
	},
	tweak_background = {
		-- Matches Ghostty's background, so the Neovim area has no visible seam.
		normal = "#0c0c0c",
		popup = "#191919",
		menu = "#0c0c0c",
		telescope = "#0c0c0c",
	},
})

vim.cmd.colorscheme("lackluster")

-- Lackluster sets the @* groups directly rather than linking them, so both
-- names must be listed. Contrast floor on #0c0c0c: 4.5:1 for text (WCAG SC
-- 1.4.3), 3:1 for UI chrome (SC 1.4.11), keeping the original brightness order.
-- The last two entries pull string escapes out of green into the blue family.
local overrides = {
	["#666666"] = {
		"SignColumn",
		"FoldColumn",
		"NonText",
		"Whitespace",
		"WinSeparator",
		"VertSplit",
	},
	["#7a7a7a"] = {
		"Comment",
		"@comment",
		"@comment.documentation",
		"DiagnosticHint",
		-- Everything below sat between 1.72:1 and 3.41:1 before this line.
		"LineNr",
		"SpecialComment",
		"@attribute",
		"@markup.italic",
		"@markup.strong",
		"@markup.list",
		"@markup.link.url",
		"@markup.strikethrough",
		"@tag.attribute",
		"DiagnosticOk",
		"DiagnosticUnnecessary",
		"DiagnosticDeprecated",
		"DiagnosticVirtualTextHint",
		"DiagnosticVirtualTextOk",
		"CmpItemAbbrDeprecated",
		"Folded",
		"GitSignsAdd",
	},
	["#8a8a8a"] = {
		"Statement",
		"@keyword.exception",
		"@markup.heading",
		"@tag",
		"@tag.builtin",
		"@tag.delimiter",
		"Directory",
		"DiffIndexLine",
		"DiffOldFile",
		"DiffText",
		"NvimTreeFolder",
		"NvimTreeFolderIcon",
		"NvimTreeRootFolder",
		"TelescopeResultsNormal",
		"Keyword",
		"@keyword",
		"@keyword.function",
		"@keyword.return",
		"@keyword.operator",
		"Conditional",
		"Repeat",
		"PreProc",
		"@label",
	},
	["#9a9a9a"] = {
		"Function",
		"@function",
		"@function.call",
		"@function.method",
		"@function.builtin",
		"@module.builtin",
	},
	["#aaaaaa"] = { "DiagnosticInfo", "DiagnosticVirtualTextInfo", "Title", "FloatTitle" },
	["#cccccc"] = { "DiagnosticWarn", "DiagnosticVirtualTextWarn" },
	-- Staged git signs, each lifted along its own hue to 4.5:1 rather than flattened to grey.
	["#5e8266"] = {
		"GitSignsStagedAdd",
		"GitSignsStagedAddCul",
		"GitSignsStagedAddNr",
		"GitSignsStagedUntracked",
		"GitSignsStagedUntrackedCul",
		"GitSignsStagedUntrackedNr",
	},
	["#4a8381"] = {
		"GitSignsStagedChange",
		"GitSignsStagedChangeCul",
		"GitSignsStagedChangeNr",
		"GitSignsStagedChangedelete",
		"GitSignsStagedChangedeleteCul",
		"GitSignsStagedChangedeleteNr",
	},
	["#95716d"] = {
		"GitSignsStagedDelete",
		"GitSignsStagedDeleteCul",
		"GitSignsStagedDeleteNr",
		"GitSignsStagedTopdelete",
		"GitSignsStagedTopdeleteCul",
		"GitSignsStagedTopdeleteNr",
	},
	[blue] = {
		"String",
		"@string",
		"@string.regexp",
		"@character",
		"@lsp.type.string",
		"@lsp.type.regexp",
	},
	[blue_bright] = { "@string.escape", "@string.special" },
}

for fg, groups in pairs(overrides) do
	for _, group in ipairs(groups) do
		vim.api.nvim_set_hl(0, group, { fg = fg })
	end
end

-- These three carry a background, and nvim_set_hl replaces an entry wholesale, so
-- they cannot ride in the fg-only table above.
-- MatchParen was #cccccc on #708090 (2.52:1); inverting it is what clears the floor.
vim.api.nvim_set_hl(0, "MatchParen", { fg = "#0c0c0c", bg = "#708090", bold = true })
vim.api.nvim_set_hl(0, "TabLine", { fg = "#8a8a8a", bg = "#191919" })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#767676", bg = "#191919" })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = "#7a7a7a", bg = "#080808" })
