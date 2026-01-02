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

require("lualine").setup({
	options = {
		icons_enabled = false,
		theme = "lackluster",
		globalstatus = true,
		component_separators = "",
		section_separators = "",
	},
	sections = {
		lualine_x = {
			SearchResultCount,
			"encoding",
			"filetype",
		},
	},
})
