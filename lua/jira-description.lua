M = {}
M.write_desc_text = function(buf, paragraph_row, col, desc, hl_ns)
  vim.api.nvim_buf_set_text(buf, paragraph_row, col, paragraph_row, col, { desc.text })
  if desc.marks ~= nil then
    for _, mark in ipairs(desc.marks) do
      if mark.type == "link" then
        vim.api.nvim_buf_add_highlight(buf, hl_ns, "String", paragraph_row, col, col + string.len(desc.text))
      end
    end
  end
end
M.write_emoji = function(buf, paragraph_row, col, inner_content)
  vim.api.nvim_buf_set_text(buf, paragraph_row, col, paragraph_row, col, { inner_content.attrs.text })
end
M.write_mention = function(buf, paragraph_row, col, inner_content, hl_ns)
  vim.api.nvim_buf_set_text(buf, paragraph_row, col, paragraph_row, col, { inner_content.attrs.text })
  print("column=", col, col + string.len(inner_content.attrs.text))
  vim.api.nvim_buf_add_highlight(buf, hl_ns, "String", paragraph_row, col, col + string.len(inner_content.attrs.text))
end
M.write_description_to_buf = function(buf, row, description, namespace)
  local lines = {}
  local row_offset = 0
  if description then
    for _, outer_content in ipairs(description.content) do
      if outer_content.type == "paragraph" then
        local paragraph_row = row + row_offset
        vim.api.nvim_buf_set_lines(buf, paragraph_row, paragraph_row, false, { "" })
        row_offset = row_offset + 1
        local col = 0
        for _, inner_content in ipairs(outer_content.content) do
          if inner_content.type == "text" then
            M.write_desc_text(buf, paragraph_row, col, inner_content, namespace)
            col = col + string.len(inner_content.text)
          end
          if inner_content.type == "emoji" then
            M.write_emoji(buf, paragraph_row, col, inner_content)
            col = col + string.len(inner_content.attrs.text)
          end
          if inner_content.type == "mention" then
            M.write_mention(buf, paragraph_row, col, inner_content, namespace)
            col = col + string.len(inner_content.attrs.text)
          end
        end
      end
    end
  else
    table.insert(lines, "No description")
  end
  return lines
end
return M
