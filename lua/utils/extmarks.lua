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
-- 0 indexed row number
M.get_extmarks_in_range = function(buf, namespace, start_row, end_row)
	local extmarks = vim.api.nvim_buf_get_extmarks(buf, namespace, 0, -1, {})
	local extmarks_in_range = {}
	print("extmark:", require("deps.json").encode(extmarks), "range:", start_row, end_row)
	for _, extmark in ipairs(extmarks) do
		if extmark[2] >= start_row and extmark[2] <= end_row then
			print("hit!")
			table.insert(extmarks_in_range, extmark)
		end
	end
	return extmarks_in_range
end
-- 0 indexed row number
M.del_extmarks_in_range = function(buf, namespace, start_row, end_row)
	local extmarks = M.get_extmarks_in_range(buf, namespace, start_row, end_row)
	for _, extmark in ipairs(extmarks) do
		vim.api.nvim_buf_del_extmark(buf, namespace, extmark[1])
	end
end
return M
