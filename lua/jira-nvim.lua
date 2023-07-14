local json = require("deps.json")
local jira_api = require("jira-api")
local buf_util = require("buffer-util")
local M = {}
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
end
M.test = function()
	buf = buf_util.create_buf()
	-- Query for data,
	local result = jira_api.jql_req(M.opts)
	-- loop through and insert data into buf_lines
	local buf_lines = {}
	for _, issue in pairs(result.issues) do
		table.insert(buf_lines, issue.key .. " " .. issue.fields.summary)
	end
	-- write buf_lines into buffer
	vim.api.nvim_buf_set_lines(buf, 0, 0, false, buf_lines)
end
M.get_issue_by_key = function(key)
	if key == nil then
		print("arg is nill!")
		return
	end
	local buf = buf_util.create_buf()
	local result = jira_api.get_issue_by_key(key, M.opts)
	local buf_lines = M.issues_to_buf_line_table(result.issues)
	-- write buf_lines into buffer
	vim.api.nvim_buf_set_lines(buf, 0, 0, false, buf_lines)
end
M.get_issue_by_text = function(text, project)
	if text == nil then
		print("arg is nill!")
		return
	end
	print(project)
	local buf = buf_util.create_buf()
	local opts_override = M.opts
	opts_override.fields = "summary,description"
	if project then
		opts_override.jql = "project=" .. project
	end
	local result = jira_api.get_issue_by_text(text, opts_override)
	local buf_lines = M.issues_to_buf_line_table(result.issues)
	-- write buf_lines into buffer
	vim.api.nvim_buf_set_lines(buf, 0, 0, false, buf_lines)
end
M.issues_to_buf_line_table = function(issues)
	local buf_lines = {}
	if issues and issues[1] then
		for _, issue in pairs(issues) do
			table.insert(buf_lines, issue.key .. " " .. issue.fields.summary)
		end
	else
		table.insert(buf_lines, "No issues found!")
	end
	return buf_lines
end
M.expand = function()
	local buf = vim.api.nvim_get_current_buf()
	local cursor_pos = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())
	local current_line = vim.api.nvim_get_current_line()
	-- close current expansion if it exists
	if M.expanded then
		vim.api.nvim_buf_set_lines(buf, M.expanded.line, M.expanded.line + M.expanded.line_count, false, {})
	end
	-- get issue key from current line
	local separator_index = string.find(current_line, " ")
	local issue_key = string.sub(current_line, 0, separator_index - 1)
	-- override opts before getting issue info
	local override_opts = M.opts
	override_opts.fields = "summary,description"
	local result = jira_api.get_issue_by_key(issue_key, override_opts)
	-- parse description (jiras data is filthy complicated!)
	local desc = json.encode(result.issues[1].fields.description)
	local lines_to_add = {}
	for _, content in pairs(result.issues[1].fields.description.content) do
		if content.type == "paragraph" then
			for _, paragraph in pairs(content.content) do
				if paragraph.type == "text" then
					table.insert(lines_to_add, "  " .. paragraph.text)
				end
			end
		end
	end
	-- set expanded
	M.expanded = { line = cursor_pos[1], line_count = table.maxn(lines_to_add) }
	-- write new expanded to buffer!
	vim.api.nvim_buf_set_lines(buf, cursor_pos[1], cursor_pos[1], false, lines_to_add)
end
M.expanded = nil
return M
