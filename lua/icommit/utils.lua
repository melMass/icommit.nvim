---@class IcommitUtils
local M = {}

--- Commit the changes with the given commit message.
---@param commit_message string: The commit message.
M.do_commit = function(commit_message)
	local cmd = "git commit -m '" .. commit_message .. "'"

	local exit_code, commit_output = vim.fn.systemlist(cmd)
	print("Exit code", vim.inspect(exit_code))
	print("Stdout", commit_output)
	local rev_parse_cmd = "git rev-parse HEAD"

	local commit_hash = vim.fn.systemlist(rev_parse_cmd)[1]
	local commit_hash_text = "Committed " .. commit_hash

	vim.api.nvim_echo({
		{ commit_hash_text, "Todo" },
		{ " ", nil },
		{ commit_message, "Title" },
	}, true, {})
end

--- Convert the content of a buffer to a string.
---@param bufnr number: The buffer number.
---@return string: The content of the buffer as a string.
M.buffer_to_string = function(bufnr)
	local content = vim.api.nvim_buf_get_lines(bufnr, 0, vim.api.nvim_buf_line_count(bufnr), false)
	return table.concat(content, "\n")
end

--- Convert a string to a table of lines.
---@param str string: The input string.
---@return table: A table containing each line of the input string.
M.string_to_lines = function(str)
	local lines = {}
	for line in string.gmatch(str, "([^\n]+)") do
		table.insert(lines, line)
	end
	return lines
end

--- Insert lines into a buffer, move the cursor to the end, and start insert mode.
---@param lines table: A table of lines to insert.
---@param winid number: The window ID where the buffer is displayed.
---@param bufnr number: The buffer number where the lines will be inserted.
M.insert_to_buffer = function(lines, winid, bufnr)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.api.nvim_win_set_cursor(winid, { #lines, 0 })
	vim.api.nvim_set_current_win(winid)

	vim.cmd("startinsert!")
end
return M
