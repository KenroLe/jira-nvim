local string_util = require("utils.string-util")
local ns_provider = require("namespace-provider")
local codeblock = require("codeblock")
local extmark_util = require("utils.extmarks")
local M = {}
M.write_desc_text = function(buf, paragraph_row, col, desc)
	vim.api.nvim_buf_set_text(buf, paragraph_row, col, paragraph_row, col, { desc.text })
	if desc.marks ~= nil then
		for _, mark in ipairs(desc.marks) do
			if mark.type == "link" then
				vim.api.nvim_buf_add_highlight(
					buf,
					ns_provider.get_ns(),
					"String",
					paragraph_row,
					col,
					col + string.len(desc.text)
				)
			end
		end
	end
end
M.write_emoji = function(buf, paragraph_row, col, inner_content)
	vim.api.nvim_buf_set_text(buf, paragraph_row, col, paragraph_row, col, { inner_content.attrs.text })
end
M.write_mention = function(buf, paragraph_row, col, inner_content)
	vim.api.nvim_buf_set_text(buf, paragraph_row, col, paragraph_row, col, { inner_content.attrs.text })
	vim.api.nvim_buf_add_highlight(
		buf,
		ns_provider.get_ns(),
		"String",
		paragraph_row,
		col,
		col + string.len(inner_content.attrs.text)
	)
end
-- returns the number of lines added
-- opts {
-- 		prefix = String, string to prefix to every paragraph line
-- }
M.write_paragraph = function(paragraph, buf, row, opts)
	local lines_added = 0
	if paragraph.type == "paragraph" then
		local prefix = ""
		if opts and opts.prefix then
			prefix = opts.prefix
		end
		-- create a new row for the paragraph
		vim.api.nvim_buf_set_lines(buf, row, row, true, { prefix })
		lines_added = lines_added + 1
		local col = string.len(prefix)
		for _, inner_content in ipairs(paragraph.content) do
			if inner_content.type == "text" then
				M.write_desc_text(buf, row, col, inner_content)
				col = col + string.len(inner_content.text)
			end
			if inner_content.type == "emoji" then
				M.write_emoji(buf, row, col, inner_content)
				col = col + string.len(inner_content.attrs.text)
			end
			if inner_content.type == "mention" then
				M.write_mention(buf, row, col, inner_content)
				col = col + string.len(inner_content.attrs.text)
			end
			if inner_content.type == "hardBreak" then
				local hb_prefix = ""
				for i = 1, string.len(prefix), 1 do
					hb_prefix = hb_prefix .. " "
				end
				print("hb_prefix", string.len(hb_prefix), " ", string.len(prefix))
				vim.api.nvim_buf_set_lines(buf, row, row, true, { hb_prefix })
				lines_added = lines_added + 1
				col = string.len(hb_prefix)
			end
		end
	end
	return lines_added
end
M.write_bullet_list = function(bullet_list, buf, row)
	local lines_added = 0
	for _, list_item in ipairs(bullet_list.content) do
		lines_added = lines_added + M.write_list_item(list_item, buf, row + lines_added)
	end
	return lines_added
end
-- returns number of lines added
M.write_list_item = function(list_item, buf, row)
	local lines_added = 0
	for _, content in ipairs(list_item.content) do
		lines_added = lines_added + M.write_paragraph(content, buf, row + lines_added, { prefix = " - " })
	end
	return lines_added
end
-- returns number of rows added
M.write_description = function(buf, row, description)
	local row_offset = 0
	if description then
		for _, outer_content in ipairs(description.content) do
			if outer_content.type == "paragraph" then
				row_offset = row_offset + M.write_paragraph(outer_content, buf, row + row_offset)
			end
			if outer_content.type == "codeBlock" then
				row_offset = row_offset + codeblock.write_codeblock(buf, outer_content, row + row_offset)
			end
			if outer_content.type == "bulletList" then
				row_offset = row_offset + M.write_bullet_list(outer_content, buf, row + row_offset)
			end
		end
	end
	return row_offset
end
M.remove_description = function(buf, row, issue)
	if issue.expanded ~= nil then
		extmark_util.del_extmarks_in_range(buf, ns_provider.get_codeblock_ns(), row, row + issue.expanded)
		vim.api.nvim_buf_set_lines(buf, row, row + issue.expanded, true, {})
		issue.expanded = nil
	end
end
return M
