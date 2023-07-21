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
      local codeblock_content = nil
      if extmark then
        codeblock_content = codeblock.get_codeblock(buf, extmark[1])
      end
      if codeblock_content == nil then
        core.expand()
        return
      end
      codeblock.display_codeblock_new_buf(codeblock_content)
    end
  end, { buffer = true, noremap = true })
end
return M
