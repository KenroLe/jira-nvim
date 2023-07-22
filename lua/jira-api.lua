local curl = require("plenary.curl")
local json = require("deps.json")
local M = {}
M.jql_req = function(jql, start_index, url, api_key, email, fields)
	local auth = email .. ":" .. api_key
	-- print(
	-- 	"url:",
	-- 	url .. "/rest/api/3/search?fields=" .. fields .. "&jql=" .. jql .. "&startIndex=" .. start_index
	-- )
	local res = curl.request({
		request = "GET",
		url = M.url_encode_spaces(
			url .. "/rest/api/3/search?fields=" .. fields .. "&jql=" .. jql .. "&startAt=" .. start_index
		),
		accept = "application/json",
		auth = auth,
	})
	return json.decode(res.body)
end
M.get_issue = function(search_opts, fields, opts)
	local jql = ""
	local start_index = 0
	if search_opts.text then
		jql = jql .. "text~ " .. search_opts.text
	end
	if search_opts.project then
		jql = jql .. " AND project =" .. search_opts.project
	end
	jql = jql .. " order by created DESC"
	if search_opts.start_index then
		start_index = search_opts.start_index
	end
	return M.jql_req(jql, start_index, opts.url, opts.api_key, opts.email, fields)
end
M.url_encode_spaces = function(url)
	return string.gsub(url, " ", "%%20")
end
return M
