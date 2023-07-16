local json = require("deps.json")
local jira_api = require("jira-api")
local buf_handle = require("buffer")
local M = {}
M.lines = {}
M.init = function()
	local token = os.getenv("jira_api_token")
	local email = os.getenv("jira_email")
	local url = os.getenv("jira_url")
	M.opts = {
		url = url,
		email = email,
		api_key = token,
		fields = "summary",
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
		print("arg is nill!")
		return
	end
	print(project)
	local buf = buf_handle.get_buf()
	local opts_override = M.opts
	opts_override.fields = "summary,description"
	if project then
		opts_override.jql = "project=" .. project
	end
	local result = jira_api.get_issue_by_text(text, opts_override)
	M.issues_to_buf_line_table(result.issues)
	-- write buf_lines into buffer
	M.render(buf)
end
M.issues_to_buf_line_table = function(issues)
	if issues and issues[1] then
		for _, issue in pairs(issues) do
			M.lines[issue.key] = {
				title = issue.key .. " " .. issue.fields.summary,
				detail = M.description_to_lines(issue.fields.description),
				expanded = false,
			} --
		end
	else
		table.insert(M.lines, "No issues found!")
	end
end
M.render = function(buf)
	local buffer_text = {}
	for _, line in pairs(M.lines) do
		table.insert(buffer_text, line.title)
	end
	vim.api.nvim_buf_set_lines(buf, 0, 0, false, buffer_text)
end
M.description_to_lines = function(description)
	local lines = {}
	if description then
		for _, content in pairs(description.content) do
			if content.type == "paragraph" then
				for _, paragraph in pairs(content.content) do
					if paragraph.type == "text" then
						table.insert(lines, paragraph.text)
					end
				end
			end
		end
	else
		table.insert(lines, "No description")
	end
	return lines
end
M.expand = function()
	local win = vim.api.nvim_get_current_win()
	local cursor_pos = vim.api.nvim_win_get_cursor(win)
	local buf = vim.api.nvim_get_current_buf()
	local line = vim.api.nvim_get_current_line()
	local range_end = string.find(line, " ")
	local issue_key = string.sub(line, 0, range_end - 1)
	local buffer_text = {}
	if M.lines[issue_key].expanded == false then
		for _, detail_line in pairs(M.lines[issue_key].detail) do
			table.insert(buffer_text, "  " .. detail_line)
			M.lines[issue_key].expanded = true
		end
		vim.api.nvim_buf_set_lines(buf, cursor_pos[1], cursor_pos[1], false, buffer_text)
	end
end
M.close = function()
	local win = vim.api.nvim_get_current_win()
	local cursor_pos = vim.api.nvim_win_get_cursor(win)
	local buf = vim.api.nvim_get_current_buf()
	local line = vim.api.nvim_get_current_line()
	local range_end = string.find(line, " ")
	local issue_key = string.sub(line, 0, range_end - 1)
	if M.lines[issue_key].expanded == true then
		local detail_len = #M.lines[issue_key].detail
		vim.api.nvim_buf_set_lines(buf, cursor_pos[1], cursor_pos[1] + detail_len, false, {})
		M.lines[issue_key].expanded = false
	end
end
return M
