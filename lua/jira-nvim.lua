local customfields = require("customfields")
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
end
return M
