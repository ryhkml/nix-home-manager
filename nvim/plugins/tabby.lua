-- https://github.com/nanozuki/tabby.nvim
local theme = {
	fill = "TabLineFill",
	head = "TabLine",
	current_tab = { fg = "#ffffff", bg = "#526596" },
	tab = "TabLine",
	win = "TabLine",
	tail = "TabLine",
}

local function PlainTabName(name)
	return name:gsub("%[%d+%+%]", "")
end

require("tabby").setup({
	line = function(line)
		return {
			{
				{ " Nvim ", hl = theme.head },
				line.sep("", theme.head, theme.fill),
			},
			line.tabs().foreach(function(tab)
				local hl = tab.is_current() and theme.current_tab or theme.tab
				return {
					line.sep("", hl, theme.fill),
					PlainTabName(tab.name()),
					line.sep("", hl, theme.fill),
					hl = hl,
					margin = " ",
				}
			end),
			line.spacer(),
			{
				line.sep("", theme.tail, theme.fill),
				{ " EMBRACE TRADITION ", hl = theme.tail },
			},
			hl = theme.fill,
		}
	end,
	option = {
		nerdfont = true,
		lualine_theme = "lackluster",
	},
})
