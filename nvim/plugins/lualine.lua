local function SearchResultCount()
	if vim.v.hlsearch == 0 then
		return ""
	end
	local last = vim.fn.getreg("/")
	if not last or last == "" then
		return ""
	end
	local searchcount = vim.fn.searchcount({ maxcount = 9000 })
	return "" .. searchcount.current .. "/" .. searchcount.total .. ""
end

-- The lackluster lualine theme puts #DDDDDD on #708090 in the mode block, which is 2.99:1,
-- and #444444 on #080808 for an inactive window, which is 2.06:1.
-- Inverting the mode block reaches 4.82:1 and keeps it reading as a badge.
local theme = vim.deepcopy(require("lualine.themes.lackluster"))
for _, mode in pairs(theme) do
	if mode.a and mode.a.bg == "#708090" then
		mode.a.fg = "#0c0c0c"
	end
end
for _, section in pairs(theme.inactive) do
	section.fg = "#7a7a7a"
end

require("lualine").setup({
	options = {
		icons_enabled = false,
		theme = theme,
		globalstatus = true,
		component_separators = "",
		section_separators = "",
	},
	sections = {
		-- Section b is spelled out only to recolour diff and diagnostics.
		-- Its background is #242424, where the theme's own values land between 2.08:1 and 4.37:1.
		lualine_b = {
			"branch",
			{
				"diff",
				diff_color = {
					added = { fg = "#9a9a9a" },
					modified = { fg = "#9a9a9a" },
					removed = { fg = "#e08a3c" },
				},
			},
			{
				"diagnostics",
				diagnostics_color = {
					error = { fg = "#ff4d4f" },
					warn = { fg = "#cccccc" },
					info = { fg = "#aaaaaa" },
					hint = { fg = "#9a9a9a" },
				},
			},
		},
		lualine_x = {
			SearchResultCount,
			"encoding",
			"filetype",
		},
	},
})
