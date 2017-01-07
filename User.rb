require 'json'
require_relative './Database'

class User
	@@db ||= Database.new()

	attr_accessor :phone_number, :type, :first_name, :last_name, :salted_password

	def initialize(hash)
		@phone_number = ""
		@type = "user"
		@first_name = ""
		@last_name = ""
		self.update(hash)
	end

	def update(hash)
		@phone_number = hash["phone_number"].to_s if hash["phone_number"] 
		@id = hash["_id"].to_s if hash["_id"] 
		@type = hash["type"] if hash["type"] 
		@first_name = hash["first_name"] if hash["first_name"] 
		@last_name = hash["last_name"] if hash["last_name"] 
		@salted_password = BCrypt::Password.create(hash["password"]) if hash["password"]
	end

	def find(query={})
		@@db.find("users",query)
	end

	def save()
		@@db.insert("users",self.format())
	end

	def overwrite()
		@@db.update("users",{"_id"=>BSON::ObjectId.from_string(@id)},self.format())
	end

	def format()
		user = {
			"phone_number"=>@phone_number,
			"type"=>@type,
			"first_name"=>@first_name,
			"last_name"=>@last_name
		}
		user["_id"] = @id if @id
		user["salted_password"] = @salted_password if @salted_password
		return user
	end

	def stringify()
		return self.format().to_json
	end

end