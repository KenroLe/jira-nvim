local M = {}
M.namespace = nil
M.get_ns = function()
	if M.namespace then
		return M.namespace
	else
		M.namespace = vim.api.nvim_create_namespace("jira-nvim")
		return M.namespace
	end
end
return M
