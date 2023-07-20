local string_util = require("utils.string-util")
local ns_provider = require("namespace-provider")
local M = {}
M.codeblocks = {}
-- opens a codeblock in a new buffer
M.display_codeblock_new_buf = function(code_block)
	vim.api.nvim_command("new")
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_option(buf, "filetype", code_block.attrs.language)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	for _, content in ipairs(code_block.content) do
		vim.api.nvim_buf_set_lines(buf, 0, 0, false, string_util.split(content.text, "\n"))
	end
end
-- returns number of lines created
M.write_codeblock = function(buf, code_block, row)
	for _, content in ipairs(code_block.content) do
		vim.api.nvim_buf_set_lines(buf, row, row, false, { "Codeblock" })
		local lines = string_util.split(content.text, "\n")
		local virt_text_lines = {}
		for _, v in ipairs(lines) do
			table.insert(virt_text_lines, { { v, "String" } })
		end
		local extmark_id = vim.api.nvim_buf_set_extmark(buf, ns_provider.get_codeblock_ns(), row, 0, { --
			end_row = row,
			hl_group = "Title",
			virt_text = { { code_block.attrs.language }, { "codeblock", "Title" } },
			virt_text_pos = "right_align",
			virt_lines = virt_text_lines,
		})
		M.set_codeblock(buf, extmark_id, code_block)
		return 1
	end
end
M.get_codeblock = function(buf, extmark_id)
	return M.codeblocks[buf .. ":" .. extmark_id]
end
M.set_codeblock = function(buf, extmark_id, codeblock)
	M.codeblocks[buf .. ":" .. extmark_id] = codeblock
end
return M
