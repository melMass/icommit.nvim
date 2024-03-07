---@class IcommitUtils
local M = {}

---Return true if the last shell command errored out
---@return boolean: true if there was an error
function M.shell_error()
	return vim.v.shell_error ~= 0
end

---Simple styled error log, title can be nil
---@param title string: the title, defaults to "ERROR"
---@param message string: the main message
function M.print_error(title, message)
	vim.api.nvim_echo({
		{ title or "ERROR:", "@error" },
		{ " ", nil },
		{ message, "Title" },
	}, true, {})
end

---Simple styled success log, title can be nil
---@param title string: the title, defaults to "ERROR"
---@param message string: the main message
function M.print_success(title, message)
	vim.api.nvim_echo({
		{ title or "SUCCESS:", "healthSuccess" },
		{ " ", nil },
		{ message, "Title" },
	}, true, {})
end

--Save the commit message to a global variable (in case of error for instance)
---@param message string: the commit message
function M.save_commit(message)
	_G.icommit_saved_commit = message
end

--- Checks if there are staged changes.
---@return boolean: true if there are staged changes, false otherwise.
function M.has_staged_changes()
	local cmd = "git diff --cached --name-only"
	local output = vim.fn.systemlist(cmd)
	if vim.v.shell_error == 0 and #output > 0 then
		return true
	else
		return false
	end
end

---Commit the changes with the given commit message.
---@param commit_message string: The commit message.
function M.do_commit(commit_message)
	local cmd = 'git commit -m "' .. commit_message:gsub('"', '\\"') .. '"'
	print("Running " .. cmd)
	local command_output = vim.fn.systemlist(cmd)

	if M.shell_error() then
		M.print_error("Could not commit", table.concat(command_output or {}))
		M.save_commit(commit_message)
		return
	end
	local commit_hash = vim.fn.systemlist("git rev-parse HEAD")[1]
	local commit_hash_text = "Committed " .. commit_hash

	vim.api.nvim_echo({
		{ commit_hash_text, "Todo" },
		{ " ", nil },
		{ commit_message, "Title" },
	}, true, {})
end

---Convert the content of a buffer to a string.
---@param bufnr number: The buffer number.
---@return string: The content of the buffer as a string.
function M.buffer_to_string(bufnr)
	local content = vim.api.nvim_buf_get_lines(bufnr, 0, vim.api.nvim_buf_line_count(bufnr), false)
	return table.concat(content, "\n")
end

---Convert a string to a table of lines.
---@param str string: The input string.
---@return table: A table containing each line of the input string.
function M.string_to_lines(str)
	local lines = {}
	for line in string.gmatch(str, "([^\n]+)") do
		table.insert(lines, line)
	end
	return lines
end

---Insert lines into a buffer, move the cursor to the end, and start insert mode.
---@param lines table: A table of lines to insert.
---@param winid number: The window ID where the buffer is displayed.
---@param bufnr number: The buffer number where the lines will be inserted.
function M.insert_to_buffer(lines, winid, bufnr)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.api.nvim_win_set_cursor(winid, { #lines, 0 })
	vim.api.nvim_set_current_win(winid)

	vim.cmd("startinsert!")
end
return M
