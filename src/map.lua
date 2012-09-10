--[[
	MAP
	Map data structure.
]]

class "map" {
	__init__ = function(self, layout, dynamic, tileset, environment, name)
		self.layout = layout
		self.dynamic = dynamic or {} --holds dynamic tiles
		self.tileset = tileset
		self.name = name or "Untitled Area"
		self.posX = 0
		self.posY = 0
		self.env = environment or {["friction"] = 1000, ["gravity"] = 600, ["tileSize"] = 16}
		self.width = # layout[2][1]
		self.height = # layout[2]
		self.batch = {}
		for x = 1, # layout do
			self.batch[x] = love.graphics.newSpriteBatch(tileset.img, 9000)
		end
		
		self.animatedTiles = {}
		--Draw the map
		print("Raw data for " .. self.name)
		local renderTime = love.timer.getMicroTime()
		for z = 1, # layout do
			self.batch[z]:bind()
			for y = 0, # layout[z] - 1 do
				for x = 0, # layout[z][y + 1] - 1 do
					local currentTile = tileset.tile[layout[z][y + 1][x + 1]]
					local id = self.batch[z]:addq(currentTile.quad, x * 16, y * 16)
					if currentTile.property.frame then
						table.insert(self.animatedTiles, id)
					end
				end
			end
			self.batch[z]:unbind()
		end
		--initialise dynamic tiles
		for k, dyn in ipairs(self.dynamic) do
			if dyn.load then dyn:load() end
		end 
		
		local renderTime = love.timer.getMicroTime() - renderTime
		print("\tCompile time: " .. renderTime .. "s")
		print("\tAnimated tiles: " .. # self.animatedTiles)
		
	end,
	
	update = function(self, dt, t, offsetX, offsetY)
		for k, id in ipairs(self.animatedTiles) do
			--animation function
		end
		
		for k, dyn in ipairs(self.dynamic) do
			dyn:update(dt, t, offsetX, offsetY)
		end
		
	end,
	
	draw = function(self, layer)
		local layer = layer or 2
		if layer == 2 then
			for k, dyn in ipairs(self.dynamic) do
				dyn:draw()
			end
		end
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(self.batch[layer], self.posX + self.offsetX, self.posY + self.offsetY)
	end,
	
	pass = function(self, x, y)
		if y <= 0 or y > # self.layout[2] then return nil end
		if x <= 0 or x > # self.layout[2][y] then return nil end
		return self.tileset.tile[self.layout[2][y][x]].property.pass--return passability property of xy
	end,
	
	heightMap = function(self, x, y)
		return self.tileset.tile[self.layout[2][y][x]].property.heightMap --return heightMap property of xy
	end
}

--dynamic tiles
class "dynTile" {
}
	