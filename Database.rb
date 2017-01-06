require 'mongo'

class Database
	def initialize()
		@db ||= self.connect() 
	end

	def connect()
		puts "connecting!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'buddy')
		return client.database
	end

	def insert(collection,object)
		@db[collection.to_sym].insert_one(object)
	end

	def update(collection,query,object)
		@db[collection.to_sym].update_one(query,{"$set"=>object})
	end

	def delete(collection,query)
		@db[collection.to_sym].delete_one(query)
	end

	def get(collection,query)
		@db[collection.to_sym].find(query)
	end

	def find_one(collection,query)
		@db[collection.to_sym].find(query).first
	end

end