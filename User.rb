require 'json'
require 'bson'
require 'bcrypt'
require_relative './Database'
require_relative './Session'

class User
	@@db ||= Database.new()

	attr_accessor :phone_number, :type, :first_name, :last_name, :salted_password, :dispensary_id

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
		@salted_password = BCrypt::Password.create(hash["password"]) if hash["password"]
		@salted_password = hash["salted_password"] if hash["salted_password"]
		@dispensary_id = hash["dispensary_id"] if hash["dispensary_id"]
	end

	def login()
		user = self.format()
		user.delete("_id")
		session = user.merge!({"last_request"=>Time.now + (60 * 5)})
		puts session
		session = Session.new(session)
		session.save
		db_result = @@db.find_one("sessions",{"phone_number"=>@phone_number})

		new_sesh = Session.new(db_result)
		new_sesh.format()
	end

	def generate_session_id()
		return BSON::ObjectId.new.to_s 
	end

	def find(query={})
		@@db.find("users",query)
	end

	def save()
		@@db.insert("users",self.format())
	end

	def overwrite()
		# do not overwrite _id
		user = self.format()
		user.delete("_id")
		@@db.update("users",{"_id"=>BSON::ObjectId.from_string(@id)},user)
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
		user["dispensary_id"] = @dispensary_id if @dispensary_id
		return user
	end

	def stringify()
		return self.format().to_json
	end

end