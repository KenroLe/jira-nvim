local customfields = require("customfields")
local ns_provider = require("namespace-provider")
local codeblock = require("codeblock")
local core = require("core")
local M = {}
M.init = function(opts)
	local token = os.getenv("jira_api_token")
	local email = os.getenv("jira_email")
	local url = os.getenv("jira_url")
	core.opts = {
		url = url,
		email = email,
		api_key = token,
	}
	customfields.set_storypoint_customfield(opts.storypoint_customfield_id)
	vim.keymap.set("n", "<leader>jie", function()
		local buf = vim.api.nvim_get_current_buf()
		local ft = vim.api.nvim_buf_get_option(buf, "filetype")
		if ft == "jira-nvim" then
			core.expand()
		end
	end)
	vim.keymap.set("n", "<leader>jix", function()
		local buf = vim.api.nvim_get_current_buf()
		local ft = vim.api.nvim_buf_get_option(buf, "filetype")
		if ft == "jira-nvim" then
			core.close()
		end
	end)
	vim.keymap.set("n", "<leader>jic", function()
		local buf = vim.api.nvim_get_current_buf()
		local ft = vim.api.nvim_buf_get_option(buf, "filetype")
		if ft == "jira-nvim" then
			local extmark = require("utils.extmarks").get_extmark_at_cursor(buf, ns_provider.get_codeblock_ns())
			local codeblock_content = codeblock.get_codeblock(buf, extmark[1])
			codeblock.display_codeblock_new_buf(codeblock_content)
		end
	end)
end
return M
