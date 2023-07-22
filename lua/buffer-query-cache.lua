local M = {}
M.query = {} -- key into with the buffer id
M.set_prev_query = function(buf, query)
	M.query[buf] = query
end
M.get_prev_query = function(buf)
	return M.query[buf]
end
return M
