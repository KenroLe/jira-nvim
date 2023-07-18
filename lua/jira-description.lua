M = {}
M.write_desc_text = function(buf, paragraph_row, col, desc)
  vim.api.nvim_buf_set_text(buf, paragraph_row, col, paragraph_row, col, { desc.text })
  if desc.marks ~= nil then
    for _, mark in ipairs(desc.marks) do
      if mark.type == "link" then
        vim.api.nvim_buf_add_highlight(
          buf,
          M.namespace,
          "String",
          paragraph_row - 1,
          col,
          col + string.len(desc.text)
        )
      end
    end
  end
end
return M
