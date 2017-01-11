require 'json'
require_relative './Database'

class Dispensary
	@@db ||= Database.new()

	attr_accessor :name, :phone_number, :location, :driver_code, :admin_code

	def initialize(hash)
		@name = "" 
		@phone_number = "" 
		@location = "" 
		@driver_code = BSON::ObjectId.new.to_s 
		@admin_code = BSON::ObjectId.new.to_s 
		self.update(hash)
	end

	def update(hash)
		@id = hash["_id"].to_s if hash["_id"] 
		@name = hash["name"] if hash["name"]
		@phone_number = hash["phone_number"] if hash["phone_number"]
		@location = hash["location"] if hash["location"]
		@driver_code = hash["driver_code"] if hash["driver_code"]
		@admin_code = hash["admin_code"] if hash["admin_code"]
	end

	def find(query={})
		@@db.find("dispensaries",query)
	end

	def save()
		# Create new dispensary
		@@db.insert("dispensaries",self.format())

		# Find dispensary
		db_result = @@db.find_one("dispensaries",{"name"=>@name})

		# Get dispensary id
		dispensary_id = db_result["_id"].to_s

		# Create new menu
		menu = Menu.new({"dispensary_id"=>dispensary_id})		
		@@db.insert("menus",menu.format())
	end

	def overwrite()
		# do not overwrite _id
		dispensary = self.format()
		dispensary.delete("_id")
		@@db.update("dispensaries",{"_id"=>BSON::ObjectId.from_string(@id)},dispensary)
	end

	def delete()
		@@db.delete("dispensaries",{"_id"=>BSON::ObjectId.from_string(@id)})
		@@db.delete("menus",{"dispensary_id"=>@id.to_s})
	end

	def format()
		dispensary = {
			"name"=>@name,
			"phone_number"=>@phone_number,
			"location"=>@location,
			"driver_code"=>@driver_code,
			"admin_code"=>@admin_code
		}
		dispensary["_id"] = @id if @id
		return dispensary
	end

	def stringify()
		dispensary = self.format()
		dispensary.delete("admin_code")
		dispensary.delete("driver_code")
		return dispensary.to_json
	end

end