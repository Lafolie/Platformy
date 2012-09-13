--[[
	TILESHEET
	Prepare data for displaying pictures such as maps.
]]

class "tileset" {
	__init__ = function(self, filepath, properties, tileSize)
		self.img = love.graphics.newImage(filepath)
		local width = self.img:getWidth()
		local height = self.img:getHeight()
		self.tile = {}
		self.tileSize = tileSize
		local tileGrid = tileSize + 2
		
		for y = 0, (height / tileGrid) - 1 do
			for x = 0, (width / tileGrid) - 1 do
				self.tile[# self.tile + 1] = {["quad"] = love.graphics.newQuad(x * tileGrid, y * tileGrid, tileSize, tileSize, width, height), ["property"] = properties[# self.tile + 1]}
			end
		end
		print("Found " .. # self.tile .. " tiles in " .. filepath)
	end
}

class "tileProperties" {
	__init__ = function(self, pass, heightMap, frame, time)
		self.pass = pass or nil
		self.frame = frame or nil
		self.time = time or nil
		self.heightMap = heightMap or nil
	end
}