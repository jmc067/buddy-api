require 'sinatra'
require 'json'
require_relative './Dispensary'
require_relative './Menu'
require_relative './MenuItem'
require_relative './User'
require_relative './Error'

@@db ||= Database.new()

get '/' do
	"Welcome to buddy bak"
end

# Register
post '/user/register' do	
    headers({ "Access-Control-Allow-Origin" => "*"}) # cross-domain friendly

	# validate params
	required_params = ["first_name","last_name","phone_number","type","password"]
	required_params.each do |param| 
		error_bad_request("Missing Field: #{param}") if !params[param] 
	end

	# check existence
	db_result = @@db.find_one("users",{"phone_number"=>params["phone_number"]})
	error_not_found("Phone number already registered") if db_result 

	# check admin dispensary code for admin registration
	if params["type"]=="admin"
		# check for admin_code
		error_bad_request("No admin_code specified") if !params["admin_code"]	

		# check for dispensary_id
		error_bad_request("No dispensary_id specified") if !params["dispensary_id"]	

		# check existence
		db_result = @@db.find_one("dispensaries",{"_id"=>BSON::ObjectId.from_string(params["dispensary_id"])})
		error_not_found("Dispensary not found") if !db_result 

		# check admin_code match
		dispensary = Dispensary.new(db_result)
		error_unauthorized("Unauthorized") if dispensary.admin_code != params["admin_code"]  
	end

	# check driver dispensary code for driver registration
	if params["type"]=="driver"
		# check for driver_code
		error_bad_request("No driver_code specified") if !params["driver_code"]	

		# check for dispensary_id
		error_bad_request("No dispensary_id specified") if !params["dispensary_id"]	

		# check existence
		db_result = @@db.find_one("dispensaries",{"_id"=>BSON::ObjectId.from_string(params["dispensary_id"])})
		error_not_found("Dispensary not found") if !db_result 

		# check driver_code match
		dispensary = Dispensary.new(db_result)
		error_unauthorized("Unauthorized") if dispensary.driver_code != params["driver_code"]  
	end

	user = User.new(params)
	user.save
	user.stringify
end

# Update User
post '/user/update/:id' do |id|
    headers({ "Access-Control-Allow-Origin" => "*"}) # cross-domain friendly

	# check existence
	db_result = @@db.find_one("users",{"_id"=>BSON::ObjectId.from_string(id)})
	error_not_found("User not found") if !db_result 

    # format user
	user = User.new(db_result)

	# update user
	user.update(params)

	# check availability
	db_result = @@db.find_one("users",{"phone_number"=>params["phone_number"]})
	error_not_found("Phone number already registered") if db_result 

	# overwrite user
	user.overwrite
	user.stringify
end

# Search Users
get '/user/search' do 
    headers({ "Access-Control-Allow-Origin" => "*"}) # cross-domain friendly
	
	# search users    
	db_result = @@db.get("users",{})
	users = db_result.map{ |d| User.new(d).format()}
	return {"users"=>users}.to_json
end

# Login
post '/user/login' do	
    headers({ "Access-Control-Allow-Origin" => "*"}) # cross-domain friendly

	# validate params
	required_params = ["phone_number","password"]
	required_params.each do |param| 
		error_bad_request("Missing Field: #{param}") if !params[param] 
	end

	# check existence
	db_result = @@db.find_one("users",{"phone_number"=>params["phone_number"]})
	error_not_found("No accounts are registered with specified phone number") if !db_result 

	# check password
	user = User.new(db_result)
	correct_password = BCrypt::Password.new(user.salted_password)
	error_unauthorized("Incorrect phone number or password") if correct_password != params["password"]      

	session = user.login
	return {"session"=>session}.to_json
end

# Get Session
get '/user/session/:session_id' do |session_id|
    headers({ "Access-Control-Allow-Origin" => "*"}) # cross-domain friendly

	# check existence
	db_result = @@db.find_one("sessions",{"_id"=>BSON::ObjectId.from_string(session_id)})
	error_forbidden("No session found") if !db_result 

	# format session
	session = Session.new(db_result)

	return {"session"=>session.format()}.to_json
end

# Create Dispensary
post '/dispensary' do 
    headers({ "Access-Control-Allow-Origin" => "*"}) # cross-domain friendly

	# validate params
	required_params = ["name"]
	required_params.each do |param| 
		error_bad_request("Missing Field: #{param}") if !params[param] 
	end

	# check name availability
	db_result = @@db.find_one("dispensaries",{"name"=>params["name"]})
	error_bad_request("name already exists") if db_result 

    # format dispensary
	dispensary = Dispensary.new(params)

	# store dispensary
	dispensary.save
	dispensary.stringify
end

# Update Dispensary
post '/dispensary/:id' do |id|
    headers({ "Access-Control-Allow-Origin" => "*"}) # cross-domain friendly

	# check existence
	db_result = @@db.find_one("dispensaries",{"_id"=>BSON::ObjectId.from_string(id)})
	error_not_found("Dispensary not found") if !db_result 

    # format dispensary
	dispensary = Dispensary.new(db_result)

	# update dispensary
	dispensary.update(params)

	# check name availability
	db_result = @@db.find_one("dispensaries",{"name"=>params["name"]})
	error_bad_request("name already exists") if db_result 

	# overwrite dispensary
	dispensary.overwrite
	dispensary.stringify
end

# Delete Dispensary
delete '/dispensary/:id' do |id|
    headers({ "Access-Control-Allow-Origin" => "*"}) # cross-domain friendly

	# check existence
	db_result = @@db.find_one("dispensaries",{"_id"=>BSON::ObjectId.from_string(id)})
	error_not_found("Dispensary not found") if !db_result 

    # format dispensary
	dispensary = Dispensary.new(db_result)

	# delete dispensary
	dispensary.delete
	dispensary.stringify
end

# Search Dispensary
get '/dispensary/search' do 
    headers({ "Access-Control-Allow-Origin" => "*"}) # cross-domain friendly
	
	# search dispensaries    
	db_result = @@db.get("dispensaries",{})
	dispensaries = db_result.map{ |d| Dispensary.new(d).format()}
	return {"dispensaries"=>dispensaries}.to_json
end

# Create Menu Item
post '/menu/:dispensary_id' do |dispensary_id|	
    headers({ "Access-Control-Allow-Origin" => "*"}) # cross-domain friendly

	# find menu
	db_result = @@db.find_one("menus",{"dispensary_id"=>dispensary_id})
	error_not_found("Menu not found") if !db_result

	# format Menu
	menu = Menu.new(db_result)

	# format MenuItem
	menu_item = MenuItem.new(params)

	# add MenuItem
	menu.menu_items.push(menu_item.format())

	# overwrite menu
	menu.overwrite
	menu.stringify
end

# Update Menu Item
post '/menu/:dispensary_id/:code' do |dispensary_id,code|
    headers({ "Access-Control-Allow-Origin" => "*"}) # cross-domain friendly

	# find menu
	db_result = @@db.find_one("menus",{"dispensary_id"=>dispensary_id})
	error_not_found("Menu not found") if !db_result

	# format Menu
	menu = Menu.new(db_result)

	# format MenuItem
	menu_item = MenuItem.new(params)

	# remove MenuItem
	menu.menu_items = menu.menu_items.select{|item| item["code"]!=code}

	# overwrite menu
	menu.menu_items.push(menu_item.format())
	menu.overwrite
	menu.stringify
end

# Delete Menu Item
delete '/menu/:dispensary_id/:code' do |dispensary_id,code|
    headers({ "Access-Control-Allow-Origin" => "*"}) # cross-domain friendly

	# find menu
	db_result = @@db.find_one("menus",{"dispensary_id"=>dispensary_id})
	error_not_found("Menu not found") if !db_result

	# format Menu
	menu = Menu.new(db_result)

	# format MenuItem
	menu_item = MenuItem.new(params)

	# remove MenuItem
	menu.menu_items = menu.menu_items.select{|item| item["code"]!=code}

	# overwrite menu
	menu.overwrite
	menu.stringify
end

# Search Menu
get '/menu/:dispensary_id' do |dispensary_id|
    headers({ "Access-Control-Allow-Origin" => "*"}) # cross-domain friendly    

	# check store existence
	db_result = @@db.find_one("menus",{"dispensary_id"=>dispensary_id})
	error_not_found("Menu not found") if !db_result 

    # format menu
	menu = Menu.new(db_result)
	menu.stringify
end