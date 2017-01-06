def error_bad_request(msg=nil, referer="")
  error 400, { "message" => msg }.to_json
end

def error_not_found(msg=nil, referer="")
  error 404, { "message" => msg }.to_json
end
