return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup({})

		-- basic telescope configuration
		local conf = require("telescope.config").values
		local function toggle_telescope(harpoon_files)
			local file_paths = {}
			for _, item in ipairs(harpoon_files.items) do
				table.insert(file_paths, item.value)
			end

			require("telescope.pickers")
				.new({}, {
					prompt_title = "Harpoon",
					finder = require("telescope.finders").new_table({
						results = file_paths,
					}),
					previewer = conf.file_previewer({}),
					sorter = conf.generic_sorter({}),
				})
				:find()
		end

		vim.keymap.set("n", "<C-e>", function()
			toggle_telescope(harpoon:list())
		end, { desc = "Open harpoon window" })

		group("Harpoon", function(m)
			--- @param n number
			local harpoon_select = function(n)
				return function()
					harpoon:list():select(n)
				end
			end

			--- @param n number
			local harpoon_replace = function(n)
				return function()
					harpoon:list():replace_at(n)
				end
			end

			m.normal("<leader>1", harpoon_select(1), "Switch to file #[1]")
			m.normal("<leader>2", harpoon_select(2), "Switch to file #[2]")
			m.normal("<leader>3", harpoon_select(3), "Switch to file #[3]")
			m.normal("<leader>4", harpoon_select(4), "Switch to file #[4]")
			m.normal("<leader>5", harpoon_select(5), "Switch to file #[5]")
			m.normal("<leader>6", harpoon_select(6), "Switch to file #[6]")
			m.normal("<leader>7", harpoon_select(7), "Switch to file #[7]")
			m.normal("<leader>8", harpoon_select(8), "Switch to file #[8]")

			m.normal("<leader>q1", harpoon_replace(1), "Replace file #[1]")
			m.normal("<leader>q2", harpoon_replace(2), "Replace file #[2]")
			m.normal("<leader>q3", harpoon_replace(3), "Replace file #[3]")
			m.normal("<leader>q4", harpoon_replace(4), "Replace file #[4]")
			m.normal("<leader>q5", harpoon_replace(5), "Replace file #[5]")
			m.normal("<leader>q6", harpoon_replace(6), "Replace file #[6]")
			m.normal("<leader>q7", harpoon_replace(7), "Replace file #[7]")
			m.normal("<leader>q8", harpoon_replace(8), "Replace file #[8]")

			m.normal("<leader>qq", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, "Toggle [q]uick menu")

			m.normal("<leader>qc", function()
				harpoon:list():clear()
			end, "Clear all")
		end)
	end,
}
