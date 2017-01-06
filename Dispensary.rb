require 'json'
require_relative './Database'

class Dispensary
	@@db ||= Database.new()

	attr_accessor :name, :phone_number, :location, :menu_id

	def initialize(hash)
		@name = "" 
		@phone_number = "" 
		@location = "" 
		@menu_id = ""
		self.update(hash)
	end

	def update(hash)
		@id = hash["_id"].to_s if hash["_id"] 
		@name = hash["name"] if hash["name"]
		@phone_number = hash["phone_number"] if hash["phone_number"]
		@location = hash["location"] if hash["location"]
		@menu_id = hash["menu_id"] if hash["menu_id"]
	end

	def find(query={})
		@@db.find("dispensaries",query)
	end

	def save()
		@@db.insert("dispensaries",self.format())
	end

	def overwrite()
		@@db.update("dispensaries",{"_id"=>BSON::ObjectId.from_string(@id)},self.format())
	end

	def delete()
		@@db.delete("dispensaries",{"_id"=>BSON::ObjectId.from_string(@id)})
	end

	def format()
		dispensary = {
			"_id"=>@id,
			"name"=>@name,
			"phone_number"=>@phone_number,
			"location"=>@location,
			"menu_id"=>@menu_id,
		}
		return dispensary
	end

	def stringify()
		return self.format().to_json
	end

end