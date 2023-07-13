local curl = require("plenary.curl")
local json = require("deps.json")
local M = {}
-- example opts:
-- opts {
--    url = string, https/http protocol included!
--    email = string,
--    api_key = string,
--    fields = string,
--    jql = string (optional),
-- }
M.jql_req = function(opts)
	local auth = opts.email .. ":" .. opts.api_key
	if opts.jql == nil then
		opts.jql = ""
	end
	local res = curl.request({
		request = "GET",
		url = opts.url .. "/rest/api/3/search?fields=" .. opts.fields .. "&jql=" .. opts.jql,
		accept = "application/json",
		auth = auth,
	})
	return json.decode(res.body)
end
M.get_issue_by_key = function(key, opts)
	opts.jql = "key=" .. key
	return M.jql_req(opts)
end
M.get_issue_by_text = function(text, opts)
	opts.jql = "text~" .. text
	return M.jql_req(opts)
end
return M
