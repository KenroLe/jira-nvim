local M = {}
M.get_extmark_at_cursor = function(buf, namespace)
	local extmarks = vim.api.nvim_buf_get_extmarks(buf, namespace, 0, -1, {})
	local cursor = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())
	for _, extmark in ipairs(extmarks) do
		if extmark[2] == cursor[1] - 1 then
			return extmark
		end
	end
end
return M
