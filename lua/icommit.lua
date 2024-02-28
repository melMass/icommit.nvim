local M = {}
local make_command = function(opts)
	local icommit = function()
		local Input = require("nui.input")
		local Menu = require("nui.menu")

		local commit_types = opts.commit_types

		local menu_items = {}
		for type, emoji in pairs(commit_types) do
			table.insert(menu_items, Menu.item(emoji .. " " .. type))
		end

		local dropdown = Menu({
			position = "50%",
			size = {
				width = 25,
				height = 15,
			},
			border = {
				style = "single",
				text = {
					top = "[Choose a Commit Type]",
					top_align = "center",
				},
			},
			win_options = {
				winhighlight = "Normal:Normal,FloatBorder:Normal",
			},
		}, {
			lines = menu_items,
			keymap = {
				focus_next = { "j", "<Down>", "<Tab>" },
				focus_prev = { "k", "<Up>", "<S-Tab>" },
				close = { "<Esc>", "<C-c>" },
				submit = { "<CR>" },
			},
			on_close = function()
				print("Menu Closed!")
			end,
			on_submit = function(item)
				local selected_type = item.text --:gsub(" .*", "")

				local short_input = Input({
					position = "50%",
					size = {
						width = 25,
					},
					border = {
						style = "single",
						text = {
							top = "[Short Commit Message]",
							top_align = "center",
						},
					},
					win_options = {
						winhighlight = "Normal:Normal,FloatBorder:Normal",
					},
				}, {
					prompt = "> ",
					on_close = function()
						print("Short Input Closed!")
					end,
					on_submit = function(value)
						local long_input = Input({
							position = "50%",
							size = {
								width = 45,
								height = 20,
							},
							border = {
								style = "single",
								text = {
									top = "[Long Commit Message]",
									top_align = "center",
								},
							},
							win_options = {
								winhighlight = "Normal:Normal,FloatBorder:Normal",
							},
						}, {
							prompt = "> ",
							on_close = function()
								print("Long Input Closed!")
							end,
							on_submit = function(long_value)
								local commit_message = string.format("%s: %s\n\n%s", selected_type, value, long_value)
								local cmd = "git commit -m '" .. commit_message .. "'"

								local exit_code, commit_output = vim.fn.systemlist(cmd)
								print("Exit code", vim.inspect(exit_code))
								print("Stdout", commit_output)
								local rev_parse_cmd = "git rev-parse HEAD"

								local commit_hash = vim.fn.systemlist(rev_parse_cmd)[1]
								local commit_hash_text = "Committed " .. commit_hash
								local commit_msg_text = string.format("%s: %s", selected_type, value)

								vim.api.nvim_echo({
									{ commit_hash_text, "Todo" },
									{ " ", nil },
									{ commit_msg_text, "Title" },
								}, true, {})
							end,
						})

						long_input:mount()
					end,
				})

				short_input:mount()
			end,
		})

		dropdown:mount()
	end
	return icommit
end
M.setup = function(opts)
	local cfg = require("icommit.config"):set(opts):get()
	if vim.fn.executable("git") == 0 then
		print("icommit: git not in path. Aborting setup")
		return
	end
	local command = make_command(cfg)
	vim.api.nvim_create_user_command("Icommit", command, {})
end

return M
