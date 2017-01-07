require 'sinatra'
require 'json'
require_relative './Dispensary'
require_relative './Menu'
require_relative './MenuItem'
require_relative './Error'

@@db ||= Database.new()

get '/' do
	"Welcome to buddy bak"
end

# Register

# Login

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
get '/search/dispensary' do 
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