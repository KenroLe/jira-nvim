local jira_api = require("jira_api")
local M = {}
M.test = function()
	-- We save handle to window from which we open the navigation
	local start_win = vim.api.nvim_get_current_win()

	vim.api.nvim_command("botright vnew") -- We open a new vertical window at the far right
	local win = vim.api.nvim_get_current_win() -- We save our navigation window handle...
	local buf = vim.api.nvim_get_current_buf() -- ...and it's buffer handle.

	-- We should name our buffer. All buffers in vim must have unique names.
	-- The easiest solution will be adding buffer handle to it
	-- because it is already unique and it's just a number.
	vim.api.nvim_buf_set_name(buf, "Notex" .. buf)

	-- Now we set some options for our buffer.
	-- nofile prevent mark buffer as modified so we never get warnings about not saved changes.
	-- Also some plugins treat nofile buffers different.
	-- For example coc.nvim don't triggers aoutcompletation for these.
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	-- We do not need swapfile for this buffer.
	vim.api.nvim_buf_set_option(buf, "swapfile", false)
	-- And we would rather prefer that this buffer will be destroyed when hide.
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	-- It's not necessary but it is good practice to set custom filetype.
	-- This allows users to create their own autocommand or colorschemes on filetype.
	-- and prevent collisions with other plugins.
	vim.api.nvim_buf_set_option(buf, "filetype", "jql_result")
	-- For better UX we will turn off line wrap and turn on current line highlight.
	vim.api.nvim_win_set_option(win, "wrap", false)
	vim.api.nvim_win_set_option(win, "cursorline", true)

	local token = os.getenv("jira_api_token")
	local email = os.getenv("jira_email")
	local url = os.getenv("jira_url")
	local opts = {
		url = url,
		email = email,
		api_key = token,
		fields = "summary",
	}
	-- Query for data,
	local result = jira_api.jql_req(opts)
	-- loop through and insert data into buf_lines
	local buf_lines = {}
	for _, issue in pairs(result.issues) do
		table.insert(buf_lines, issue.key .. " " .. issue.fields.summary)
	end
	-- write buf_lines into buffer
	vim.api.nvim_buf_set_lines(buf, 0, 0, false, buf_lines)
end
return M
