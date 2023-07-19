local M = {}
-- set the customfield id that will be treated as storypoint field
M.set_storypoint_customfield = function(customfield_id)
  M.storypoint_cf_id = customfield_id
end
M.get_storypoint_customfield = function()
  return M.storypoint_cf_id
end
return M
