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
			print(issue.key)
			M.buf[buf].issues[issue.key] = issue
			M.buf[buf].issues[issue.key].expanded = false
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
M.write_description_to_buf = function(buf, row, description)
	local lines = {}
	local row_offset = 0
	if description then
		for _, outer_content in ipairs(description.content) do
			if outer_content.type == "paragraph" then
				local paragraph_row = row + row_offset
				vim.api.nvim_buf_set_lines(buf, paragraph_row, paragraph_row, false, { "" })
				row_offset = row_offset + 1
				local col = 0
				for _, inner_content in ipairs(outer_content.content) do
					if inner_content.type == "text" then
						require("jira-description").write_desc_text(buf, paragraph_row, col, inner_content)
						col = col + string.len(inner_content.text)
					end
					if inner_content.type == "emoji" then
						vim.api.nvim_buf_set_text(
							buf,
							paragraph_row,
							col,
							paragraph_row,
							col,
							{ inner_content.attrs.text }
						)
						col = col + string.len(inner_content.attrs.text)
					end
					if inner_content.type == "mention" then
						vim.api.nvim_buf_set_text(
							buf,
							paragraph_row,
							col,
							paragraph_row,
							col,
							{ inner_content.attrs.text }
						)
						vim.api.nvim_buf_add_highlight(
							buf,
							M.namespace,
							"String",
							row + row_offset - 1,
							col,
							col + string.len(inner_content.attrs.text)
						)
						col = col + string.len(inner_content.attrs.text)
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
	if M.buf[buf].issues[issue_key].expanded == false then
		M.write_description_to_buf(buf, cursor_pos[1], M.buf[buf].issues[issue_key].fields.description)
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
