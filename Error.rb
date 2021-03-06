def error_bad_request(msg=nil, referer="")
  error 400, { "message" => msg }.to_json
end

def error_not_found(msg=nil, referer="")
  error 404, { "message" => msg }.to_json
end

def error_unauthorized(msg="Unauthorized", referer="")
	error 401, { "message" => msg }.to_json
end

def error_forbidden(msg="Forbidden", referer="")
	error 403, { "message" => msg }.to_json
end


