local M = {}
local make_command = function(opts)
	local icommit = function()
		local Input = require("nui.input")
		local Menu = require("nui.menu")
		local Popup = require("nui.popup")

		local event = require("nui.utils.autocmd").event

		local commit_types = opts.commit_types

		local utils = require("icommit.utils")

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
			keymap = opts.keymap,
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
						local long_input = Popup({
							position = "50%",
							enter = true,
							focusable = true,
							size = {
								width = 80,
								height = 30,
							},
							border = {
								style = "single",
								text = {
									top = "[Long Commit Message]",
									top_align = "center",
								},
							},
						})

						--NOTE: map all the submit keys
						for _, shortcut in ipairs(opts.keymap.submit) do
							long_input:map("n", shortcut, function()
								local text = utils.buffer_to_string(long_input.bufnr)
								utils.do_commit(text)
								long_input:unmount()
							end, { noremap = true })
						end

						--NOTE: map all the close keys
						for _, shortcut in ipairs(opts.keymap.close) do
							long_input:map("n", shortcut, function()
								long_input:unmount()
							end, { noremap = true })
						end

						long_input:mount()

						local commit_message = string.format("%s: %s", selected_type, value)
						local lines = { commit_message, "", "" }

						utils.insert_to_buffer(lines, long_input.winid, long_input.bufnr)

						-- unmount component when cursor leaves buffer
						long_input:on(event.BufLeave, function() end)
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
