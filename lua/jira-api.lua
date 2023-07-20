local curl = require("plenary.curl")
local json = require("deps.json")
local M = {}
M.jql_req = function(jql, url, api_key, email, fields)
	local auth = email .. ":" .. api_key
	local res = curl.request({
		request = "GET",
		url = M.url_encode_spaces(url .. "/rest/api/3/search?fields=" .. fields .. "&jql=" .. jql),
		accept = "application/json",
		auth = auth,
	})
	return json.decode(res.body)
end
M.get_issue = function(search_opts, fields, opts)
	local jql = ""
	if search_opts.text then
		jql = jql .. "text~ " .. search_opts.text
	end
	if search_opts.project then
		jql = jql .. " AND project =" .. search_opts.project
	end
	return M.jql_req(jql, opts.url, opts.api_key, opts.email, fields)
end
M.url_encode_spaces = function(url)
	return string.gsub(url, " ", "%%20")
end
return M
