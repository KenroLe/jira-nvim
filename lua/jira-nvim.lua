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
M.get_issue_by_text = function(text)
	if text == nil then
		print("arg is nill!")
		return
	end
	local buf = buf_util.create_buf()
	local result = jira_api.get_issue_by_text(text, M.opts)
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
return M
