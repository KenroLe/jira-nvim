local string_util = require("utils.string-util")
local M = {}
M.is_code_block = function(row) end
-- opens a codeblock in a new buffer
M.display_codeblock_new_buf = function(code_block)
	vim.api.nvim_command("new")
	local buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_option(buf, "filetype", code_block.attrs.language)
	for _, content in ipairs(code_block.content) do
		vim.api.nvim_buf_set_lines(buf, 0, 0, false, string_util.split(content.text, "\n"))
	end
end
-- returns number of lines created
M.write_codeblock = function(buf, code_block, row)
	for _, content in ipairs(code_block.content) do
		local lines = string_util.split(content.text, "\n")
		vim.api.nvim_buf_set_lines(buf, row, row, false, lines)
		return table.maxn(lines)
	end
end
return M
