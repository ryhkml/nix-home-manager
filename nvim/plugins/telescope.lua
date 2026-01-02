-- https://github.com/nvim-telescope/telescope.nvim
require("telescope").setup({
	defaults = {
		file_ignore_patterns = {
			"^.angular/",
			"^.database/",
			"^.db/",
			"^.firebase/",
			"^.git/",
			"^dist/",
			"^node_modules/",
			"^target/",
			"%.min%.css$",
			"%.min%.js$",
		},
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--line-number",
			"--column",
			"--smart-case",
			"--hidden",
			"--no-ignore-files",
			"--no-require-git",
		},
	},
	pickers = {
		find_files = {
			hidden = true,
			no_ignore = true,
			disable_devicons = true,
			file_ignore_patterns = {
				"^.angular/",
				"^.database/",
				"^.db/",
				"^.firebase/",
				"^.git/",
				"^dist/",
				"^node_modules/",
				"^target/",
				"%.min%.css$",
				"%.min%.js$",
			},
			find_command = {
				"fd",
				".",
				"-tf",
				"--hidden",
				"--strip-cwd-prefix",
				"--no-require-git",
			},
		},
	},
	extensions = {
		fzf = {
			fuzzy = true,
			case_mode = "smart_case",
			override_file_sorter = true,
			override_generic_sorter = true,
		},
		live_grep_args = {
			auto_quoting = true,
		},
	},
})

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files)
vim.keymap.set("n", "<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
vim.keymap.set("n", "<leader>fb", builtin.buffers)
vim.keymap.set("n", "<leader>fh", builtin.help_tags)

require("telescope").load_extension("fzf")
require("telescope").load_extension("live_grep_args")
