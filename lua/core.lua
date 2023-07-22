local json = require("deps.json")
local jira_api = require("jira-api")
local buf_handle = require("buffer")
local jira_description_handler = require("jira-description")
local customfields = require("customfields")
local ns_provider = require("namespace-provider")
local buffer_query_cache = require("buffer-query-cache")
local M = {}
M.buf = {}
M.get_issue_by_text = function(text, project)
	if text == nil then
		return
	end
	local buf = buf_handle.get_buf()
	M.buf[buf] = { issues = {}, ordered_issues = {} }
	local fields = "summary,description," .. customfields.get_storypoint_customfield()
	local search_opts = { text = text, project = project, start_index = 0 }
	buffer_query_cache.set_prev_query(buf, { search_opts = search_opts, fields = fields })
	local result = jira_api.get_issue(search_opts, fields, M.opts)
	M.store_issues(buf, result.issues)
	-- write buf_lines into buffer
	M.render(buf, M.buf[buf].ordered_issues)
end
M.store_issues = function(buf, issues)
	if issues and issues[1] then
		for _, issue in ipairs(issues) do
			M.buf[buf].issues[issue.key] = issue
			M.buf[buf].issues[issue.key].expanded = nil
			-- store a ref in an ordered table
			table.insert(M.buf[buf].ordered_issues, issue)
		end
	end
end
M.render = function(buf, issues)
	local row = vim.api.nvim_buf_line_count(buf) - 1
	for _, issue in pairs(issues) do
		local end_col_index = 0
		vim.api.nvim_buf_set_lines(buf, row, row, false, { "" })
		vim.api.nvim_buf_set_text(buf, row, end_col_index, row, end_col_index, { issue.key })
		end_col_index = end_col_index + string.len(issue.key)

		if issue.fields[customfields.get_storypoint_customfield()] then
			local tmp_text = " 󰔸 " .. issue.fields[customfields.get_storypoint_customfield()]
			vim.api.nvim_buf_set_text(buf, row, end_col_index, row, end_col_index, { tmp_text })
			end_col_index = end_col_index + string.len(tmp_text)
		end
		if issue.fields.summary then
			local tmp_text = "  " .. issue.fields.summary
			vim.api.nvim_buf_set_text(buf, row, end_col_index, row, end_col_index, { tmp_text })
			end_col_index = end_col_index + string.len(tmp_text)
		end
		vim.api.nvim_buf_set_extmark(buf, ns_provider.get_ns(), row, 0, { end_row = row + 1, hl_group = "Title" })
		row = row + 1
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
			M.buf[buf].issues[issue_key].fields.description
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
M.load_more = function()
	local buf = vim.api.nvim_get_current_buf()
	local query = buffer_query_cache.get_prev_query(buf)
	query.search_opts.start_index = query.search_opts.start_index + 50
	local result = jira_api.get_issue(query.search_opts, query.fields, M.opts)
	M.store_issues(buf, result.issues)
	M.render(buf, result.issues)
end
return M
