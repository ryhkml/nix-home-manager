vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
	sync_root_with_cwd = true,
	view = {
		signcolumn = "no",
		width = 30,
	},
	renderer = {
		group_empty = true,
		indent_markers = {
			enable = true,
		},
		icons = {
			web_devicons = {
				file = {
					enable = false,
					color = false,
				},
			},
			git_placement = "after",
			symlink_arrow = " -> ",
			show = {
				file = false,
			},
			glyphs = {
				git = {
					unstaged = "US",
					staged = "S",
					unmerged = "UM",
					renamed = "R",
					untracked = "UT",
					deleted = "D",
					ignored = "i",
				},
			},
		},
		symlink_destination = false,
	},
	filters = {
		custom = { ".angular", ".git" },
		exclude = { ".github", ".gitmodules", ".gitignore", ".gitattributes" },
	},
	filesystem_watchers = {
		enable = true,
		debounce_delay = 100,
		ignore_dirs = {
			"/.angular",
			"/.ccls-cache",
			"/build",
			"/dist",
			"/node_modules",
			"/target",
		},
	},
	update_focused_file = {
		enable = true,
	},
	git = {
		enable = false,
	},
})
