require 'json'
require_relative './Database'

class Menu
	@@db ||= Database.new()

	attr_accessor :store_id, :menu_items

	def initialize(hash)
		@store_id = "" 
		@menu_items = []
		self.update(hash)
	end

	def update(hash)
		@id = hash["_id"].to_s if hash["_id"] 
		@store_id = hash["store_id"] if hash["store_id"]
		@menu_items = hash["menu_items"] if hash["menu_items"]
	end

	def find(query={})
		@@db.find("menus",query)
	end

	def save()
		@@db.insert("menus",self.format())
	end

	def overwrite()
		@@db.update("menus",{"_id"=>BSON::ObjectId.from_string(@id)},self.format())
	end

	def format()
		menu = {
			"store_id"=>@store_id,
			"menu_items"=>@menu_items,
		}
		return menu
	end

	def stringify()
		return self.format().to_json
	end

end