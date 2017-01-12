require 'json'
require_relative './Database'

class MenuItem
	@@db ||= Database.new()

	attr_accessor :name, :code, :name, :category, :type, :thc_percent, :thc_g, :description, :image, :gram_price, :eighth_price, :quarter_price, :half_price, :oz_price, :item_price

	def initialize(hash)
		@code = BSON::ObjectId.new.to_s
		self.update(hash)
	end

	def update(hash)
		@name = hash["name"].to_s if hash["name"]
		@code = hash["code"].to_s if hash["code"]
		@category = hash["category"].to_s if hash["category"]
		@type = hash["type"].to_s if hash["type"]
		@thc_percent = hash["thc_percent"].to_i if hash["thc_percent"]
		@thc_g = hash["thc_g"].to_i if hash["thc_g"]
		@description = hash["description"].to_s if hash["description"]
		@image = hash["image"].to_s if hash["image"]
		@gram_price = hash["gram_price"].to_i if hash["gram_price"]
		@eighth_price = hash["eighth_price"].to_i if hash["eighth_price"]
		@quarter_price = hash["quarter_price"].to_i if hash["quarter_price"]
		@half_price = hash["half_price"].to_i if hash["half_price"]
		@oz_price = hash["oz_price"].to_i if hash["oz_price"]
		@item_price = hash["item_price"].to_i if hash["item_price"]
	end

	def format()
		menu = {
			"name" => @name,
			"code" => @code,
			"category" => @category,
			"type" => @type,
			"thc_percent" => @thc_percent,
			"thc_g" => @thc_g,
			"description" => @description,
			"image" => @image,
			"gram_price" => @gram_price,
			"eighth_price" => @eighth_price,
			"quarter_price" => @quarter_price,
			"half_price" => @half_price,
			"oz_price" => @oz_price,
			"item_price" => @item_price
		}
		return menu
	end

	def stringify()
		return self.format().to_json
	end

end