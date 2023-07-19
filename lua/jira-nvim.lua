local jira_api = require("jira-api")
local buf_handle = require("buffer")
local jira_description_handler = require("jira-description")
local M = {}
M.buf = {}
M.namespace = nil
M.init = function()
	local token = os.getenv("jira_api_token")
	local email = os.getenv("jira_email")
	local url = os.getenv("jira_url")
	M.namespace = vim.api.nvim_create_namespace("jira-nvim")
	M.opts = {
		url = url,
		email = email,
		api_key = token,
	}
	vim.keymap.set("n", "e", function()
		local buf = vim.api.nvim_get_current_buf()
		local ft = vim.api.nvim_buf_get_option(buf, "filetype")
		if ft == "jira-nvim" then
			M.expand()
		end
	end)
	vim.keymap.set("n", "c", function()
		local buf = vim.api.nvim_get_current_buf()
		local ft = vim.api.nvim_buf_get_option(buf, "filetype")
		if ft == "jira-nvim" then
			M.close()
		end
	end)
end
M.get_issue_by_text = function(text, project)
	if text == nil then
		return
	end
	local buf = buf_handle.get_buf()
	M.buf[buf] = { issues = {} }
	local fields = "summary,description"
	local result = jira_api.get_issue({ text = text, project = project }, fields, M.opts)
	M.issues_to_buf_line_table(result.issues, buf)
	-- write buf_lines into buffer
	M.render(buf)
end
M.issues_to_buf_line_table = function(issues, buf)
	if issues and issues[1] then
		for _, issue in pairs(issues) do
			print(issue.key)
			M.buf[buf].issues[issue.key] = issue
			M.buf[buf].issues[issue.key].expanded = nil
		end
	else
		table.insert(M.buf[buf].lines, "No issues found!")
	end
end
M.render = function(buf)
	for _, issue in pairs(M.buf[buf].issues) do
		vim.api.nvim_buf_set_lines(buf, 0, 0, false, { issue.key .. " " .. issue.fields.summary })
		vim.api.nvim_buf_set_extmark(buf, M.namespace, 0, 0, { end_row = 1, hl_group = "Title" })
	end
end
M.expand = function()
	local win = vim.api.nvim_get_current_win()
	local cursor_pos = vim.api.nvim_win_get_cursor(win)
	local buf = vim.api.nvim_get_current_buf()
	local line = vim.api.nvim_get_current_line()
	local range_end = string.find(line, " ")
	local issue_key = string.sub(line, 0, range_end - 1)
	if M.buf[buf].issues[issue_key].expanded == nil then
		local lines_added_len = jira_description_handler.write_description(
			buf,
			cursor_pos[1],
			M.buf[buf].issues[issue_key].fields.description,
			M.namespace
		)
		M.buf[buf].issues[issue_key].expanded = lines_added_len
	end
end
M.close = function()
	local win = vim.api.nvim_get_current_win()
	local cursor_pos = vim.api.nvim_win_get_cursor(win)
	local buf = vim.api.nvim_get_current_buf()
	local line = vim.api.nvim_get_current_line()
	local range_end = string.find(line, " ")
	local issue_key = string.sub(line, 0, range_end - 1)
	jira_description_handler.remove_description(buf, cursor_pos[1], M.buf[buf].issues[issue_key])
end
return M
