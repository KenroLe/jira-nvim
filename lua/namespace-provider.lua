local M = {}
M.ns = nil
M.get_ns = function()
	if M.ns then
		return M.ns
	else
		M.ns = vim.api.nvim_create_namespace("jira-nvim")
		return M.ns
	end
end
M.cb_ns = nil
M.get_codeblock_ns = function()
	if M.cb_ns then
		return M.cb_ns
	else
		M.cb_ns = vim.api.nvim_create_namespace("jira-nvim-codeblock_namespace")
		return M.cb_ns
	end
end
return M
