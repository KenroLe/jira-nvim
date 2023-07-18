local jira_api = require("jira-api")
local buf_handle = require("buffer")
local M = {}
-- [
--    Issues : {
--    	IssueKey : {
--    		title:string,
--    		detail_line:{hl_group:string, text:string},
--        expanded:bool
--    	}
--    }
-- [
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
	M.opts.fields = "summary,description"
	local result = jira_api.get_issue(text, project, M.opts)
	M.issues_to_buf_line_table(result.issues, buf)
	-- write buf_lines into buffer
	M.render(buf)
end
M.issues_to_buf_line_table = function(issues, buf)
	if issues and issues[1] then
		for _, issue in pairs(issues) do
			M.buf[buf].issues[issue.key] = {
				title = issue.key .. " " .. issue.fields.summary,
				detail = M.description_to_lines(issue.fields.description),
				expanded = false,
			} --
		end
	else
		table.insert(M.buf[buf].lines, "No issues found!")
	end
end
M.render = function(buf)
	for _, line in pairs(M.buf[buf].issues) do
		vim.api.nvim_buf_set_lines(buf, 0, 0, false, { line.title })
		vim.api.nvim_buf_set_extmark(buf, M.namespace, 0, 0, { end_row = 1, hl_group = "Title" })
	end
end
M.description_to_lines = function(description)
	local lines = {}
	if description then
		for _, paragraph in pairs(description.content) do
			if paragraph.type == "paragraph" then
				local line = ""
				local url = nil
				for _, content in pairs(paragraph.content) do
					if content.type == "text" then
						line = line .. content.text
					elseif content.marks ~= nil then
						for _, mark in pairs(content.marks) do
							if mark.type == "link" then
								url = mark.attrs.href
							end
						end
					end
				end
				table.insert(lines, line)
				if url then
					table.insert(lines, "^^ URL:" .. url)
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
	if M.buf[buf].issues[issue_key].expanded == false then
		for _, detail_line in pairs(M.buf[buf].issues[issue_key].detail) do
			table.insert(buffer_text, "  " .. detail_line)
			M.buf[buf].issues[issue_key].expanded = true
		end
		vim.api.nvim_buf_set_lines(buf, cursor_pos[1], cursor_pos[1], false, buffer_text)
		vim.api.nvim_buf_set_extmark(
			buf,
			M.namespace,
			cursor_pos[1],
			0,
			{ end_row = cursor_pos[1] + table.maxn(buffer_text), hl_group = "String" }
		)
	end
end
M.close = function()
	local win = vim.api.nvim_get_current_win()
	local cursor_pos = vim.api.nvim_win_get_cursor(win)
	local buf = vim.api.nvim_get_current_buf()
	local line = vim.api.nvim_get_current_line()
	local range_end = string.find(line, " ")
	local issue_key = string.sub(line, 0, range_end - 1)
	if M.buf[buf].lines[issue_key].expanded == true then
		local detail_len = #M.buf[buf].lines[issue_key].detail
		vim.api.nvim_buf_set_lines(buf, cursor_pos[1], cursor_pos[1] + detail_len, false, {})
		M.buf[buf].lines[issue_key].expanded = false
	end
end
return M
