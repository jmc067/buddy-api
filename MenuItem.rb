require 'json'
require_relative './Database'

class MenuItem
	@@db ||= Database.new()

	attr_accessor :name, :code

	def initialize(hash)
		@name = ""
		@code = BSON::ObjectId.new.to_s
		self.update(hash)
	end

	def update(hash)
		@name = hash["name"].to_s if hash["name"] 
		@code = hash["code"].to_s if hash["code"] 
	end

	def format()
		menu = {
			"name"=>@name,
			"code"=>@code
		}
		return menu
	end

	def stringify()
		return self.format().to_json
	end

end