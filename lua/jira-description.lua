local string_util = require("utils.string-util")
M = {}
M.write_desc_text = function(buf, paragraph_row, col, desc, hl_ns)
	vim.api.nvim_buf_set_text(buf, paragraph_row, col, paragraph_row, col, { desc.text })
	if desc.marks ~= nil then
		for _, mark in ipairs(desc.marks) do
			if mark.type == "link" then
				vim.api.nvim_buf_add_highlight(buf, hl_ns, "String", paragraph_row, col, col + string.len(desc.text))
			end
		end
	end
end
M.write_emoji = function(buf, paragraph_row, col, inner_content)
	vim.api.nvim_buf_set_text(buf, paragraph_row, col, paragraph_row, col, { inner_content.attrs.text })
end
M.write_mention = function(buf, paragraph_row, col, inner_content, hl_ns)
	vim.api.nvim_buf_set_text(buf, paragraph_row, col, paragraph_row, col, { inner_content.attrs.text })
	vim.api.nvim_buf_add_highlight(buf, hl_ns, "String", paragraph_row, col, col + string.len(inner_content.attrs.text))
end
-- returns the number of lines added
M.write_paragraph = function(paragraph, buf, row, namespace)
	local lines_added = 0
	if paragraph.type == "paragraph" then
		-- create a new row for the paragraph
		vim.api.nvim_buf_set_lines(buf, row, row, false, { "" })
		lines_added = lines_added + 1
		local col = 0
		for _, inner_content in ipairs(paragraph.content) do
			if inner_content.type == "text" then
				M.write_desc_text(buf, row, col, inner_content, namespace)
				col = col + string.len(inner_content.text)
			end
			if inner_content.type == "emoji" then
				M.write_emoji(buf, row, col, inner_content)
				col = col + string.len(inner_content.attrs.text)
			end
			if inner_content.type == "mention" then
				M.write_mention(buf, row, col, inner_content, namespace)
				col = col + string.len(inner_content.attrs.text)
			end
			if inner_content.type == "hardBreak" then
				vim.api.nvim_buf_set_lines(buf, row, row, false, { "" })
				lines_added = lines_added + 1
				col = 0
			end
		end
	end
	return lines_added
end
M.display_codeblocks = function(code_block)
	vim.api.nvim_command("new")
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_option(buf, "filetype", code_block.attrs.language)
	for _, content in ipairs(code_block.content) do
		vim.api.nvim_buf_set_lines(buf, 0, 0, false, string_util.split(content.text, "\n"))
	end
end
M.write_bullet_list = function(bullet_list, buf, row, namespace)
	local lines_added = 0
	for _, list_item in ipairs(bullet_list.content) do
		lines_added = lines_added + M.write_list_item(list_item, buf, row + lines_added, namespace)
	end
	return lines_added
end
-- returns number of lines added
M.write_list_item = function(list_item, buf, row, namespace)
	local lines_added = 0
	for _, content in ipairs(list_item.content) do
		lines_added = lines_added + M.write_paragraph(content, buf, row + lines_added, namespace)
	end
	return lines_added
end
-- returns number of rows added
M.write_description = function(buf, row, description, namespace)
	local row_offset = 0
	if description then
		for _, outer_content in ipairs(description.content) do
			if outer_content.type == "paragraph" then
				row_offset = row_offset + M.write_paragraph(outer_content, buf, row + row_offset, namespace)
			end
			if outer_content.type == "codeBlock" then
				M.display_codeblocks(outer_content)
			end
			if outer_content.type == "bulletList" then
				row_offset = row_offset + M.write_bullet_list(outer_content, buf, row + row_offset, namespace)
			end
		end
	end
	return row_offset
end
M.remove_description = function(buf, row, issue)
	if issue.expanded ~= nil then
		vim.api.nvim_buf_set_lines(buf, row, row + issue.expanded, false, {})
		issue.expanded = nil
	end
end
return M
