require 'json'
require 'bson'
require 'bcrypt'
require_relative './Database'

class Session
	@@db ||= Database.new()

	attr_accessor :phone_number, :type, :first_name, :last_name

	def initialize(hash)
		@phone_number = ""
		@type = "user"
		@first_name = ""
		@last_name = ""
		@dispensary_id = ""
		self.update(hash)
	end

	def update(hash)
		@phone_number = hash["phone_number"].to_s if hash["phone_number"] 
		@id = hash["_id"].to_s if hash["_id"] 
		@type = hash["type"] if hash["type"] 
		@first_name = hash["first_name"] if hash["first_name"] 
		@last_name = hash["last_name"] if hash["last_name"] 
		@dispensary_id = hash["dispensary_id"] if hash["dispensary_id"] 
	end

	def find(query={})
		@@db.find("sessions",query)
	end

	def save()
		@@db.insert("sessions",self.format())
	end

	def overwrite()
		# do not overwrite _id
		session = self.format()
		session.delete("_id")
		@@db.update("sessions",{"_id"=>BSON::ObjectId.from_string(@id)},session)
	end

	def format()
		session = {
			"phone_number"=>@phone_number,
			"type"=>@type,
			"first_name"=>@first_name,
			"last_name"=>@last_name,
			"dispensary_id"=>@dispensary_id
		}
		session["_id"] = @id if @id
		return session
	end

	def stringify()
		return self.format().to_json
	end

end