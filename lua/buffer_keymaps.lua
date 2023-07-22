local ns_provider = require("namespace-provider")
local codeblock = require("codeblock")
local M = {}
M.set_mappings = function()
	-- vim.keymap.set("n", "e", function()
	--   local core = require("core")
	--   local buf = vim.api.nvim_get_current_buf()
	--   local ft = vim.api.nvim_buf_get_option(buf, "filetype")
	--   if ft == "jira-nvim" then
	--     core.expand()
	--   end
	-- end, { buffer = true, noremap = true })
	vim.keymap.set("n", "x", function()
		local core = require("core")
		local buf = vim.api.nvim_get_current_buf()
		local ft = vim.api.nvim_buf_get_option(buf, "filetype")
		if ft == "jira-nvim" then
			core.close()
		end
	end, { buffer = true, noremap = true })
	vim.keymap.set("n", "e", function()
		local core = require("core")
		local buf = vim.api.nvim_get_current_buf()
		local ft = vim.api.nvim_buf_get_option(buf, "filetype")
		if ft == "jira-nvim" then
			local extmark = require("utils.extmarks").get_extmark_at_cursor(buf, ns_provider.get_codeblock_ns())
			if extmark then
				local codeblock_content = codeblock.get_codeblock(buf, extmark[1])
				codeblock.display_codeblock_new_buf(codeblock_content)
				return
			end
			local extmark = require("utils.extmarks").get_extmark_at_cursor(buf, ns_provider.get_loadmore_ns())
			if extmark then
				core.load_more()
				return
			end
			core.expand()
		end
	end, { buffer = true, noremap = true })
	vim.keymap.set("n", "b", function()
		local core = require("core")
		core.load_more()
	end)
end
return M
