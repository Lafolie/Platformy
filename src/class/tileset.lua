--[[
	TILESHEET
	Prepare data for displaying pictures such as maps.
]]

class "tileset" {
	__init__ = function(self, data)
		local filepath, properties, tileSize, autoProp, tiles = unpack(data)
		--cache the image
		self.img = cache.image(filepath)
		--generate tile properties table
		self.properties = {}
		for name, prop in pairs(properties) do
			self.properties[name] = tileProperties(unpack(prop))
		end
		--generate tiles
		local width = self.img:getWidth()
		local height = self.img:getHeight()
		self.tile = {}
		self.tileSize = tileSize
		local tileGrid = tileSize + 2
		for y = 0, (height / tileGrid) - 1 do
			for x = 0, (width / tileGrid) - 1 do
				self.tile[# self.tile + 1] = {
					quad = love.graphics.newQuad(x * tileGrid, y * tileGrid, tileSize, tileSize, width, height), 
					property = self.properties[autoProp[# self.tile + 1]]
				}
			end
		end
		print("Found " .. # self.tile .. " tiles in " .. filepath)
		self:append(tiles)
	end,
	
	--add extra tiles using existing data as reference (useful for hidden passages, for example)
	append = function(self, tiles)
		tiles = tiles or {}
		for k, tile in ipairs(tiles) do
			self.tile[# self.tile + 1] = {quad = self.tile[tile[1]].quad, property = self.properties[tile[2]]}
		end
	end
}

class "tileProperties" {
	__init__ = function(self, pass, heightMap, frame, time)
		--[[
			Passabilitiy data (pass) should be stored as a number. Currently there are checks for the following:
			
				1 == left-facing ramp \
				2 == solid
				3 == right-facing ramp /
		]]
		self.pass = pass or nil
		self.frame = frame or nil --should be a table of animation data as used for sprites
		self.time = time or nil --used for animation, supply t to use
		self.heightMap = heightMap or nil --height mapping for ramps, stairs and curved surfaces
	end
}