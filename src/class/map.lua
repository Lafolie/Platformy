--[[
	MAP
	Map data structure.
]]

class "map" {
	__init__ = function(self, data)
		local layout, tileset, dynamic, environment, name, ents = unpack(data)
		self.layout = layout
		self.dynamic = dynamic or {} --holds dynamic tiles
		self.ents = ents or {}
		print(# ents)
		print(# self.ents)
		self.tileset = cache.tileset(tileset)
		self.name = name or "Untitled Area"
		self.posX = 0
		self.posY = 0
		self.env = environment or {friction = 1000, gravity = 600, tileSize = 16, oc = 2}
		self.width = # layout[self.env.oc][1]
		self.height = # layout[self.env.oc]
		self.batch = {}
		self.offsetX = love.graphics.getWidth()
		self.offsetY = love.graphics.getHeight()
		for x = 1, # layout do
			self.batch[x] = love.graphics.newSpriteBatch(self.tileset.img, self.width * self.height)
		end
		
		self.animatedTiles = {}
		--Draw the map
		print("Raw data for " .. self.name)
		local renderTime = love.timer.getMicroTime()
		for z = 1, # layout do
			self.batch[z]:bind()
			for y = 0, # layout[z] - 1 do
				for x = 0, # layout[z][y + 1] - 1 do
					local currentTile = self.tileset.tile[layout[z][y + 1][x + 1]]
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
		if y <= 0 or y > # self.layout[self.env.oc] then return nil end
		if x <= 0 or x > # self.layout[self.env.oc][y] then return nil end
		return self.tileset.tile[self.layout[self.env.oc][y][x]].property.pass--return passability property of xy
	end,
	
	properties = function(self, x, y)
		if y <= 0 or y > # self.layout[self.env.oc] then return nil end
		if x <= 0 or x > # self.layout[self.env.oc][y] then return nil end
		return self.tileset.tile[self.layout[self.env.oc][y][x]].property --return tile properties
	end,
	
	getEnts = function(self)
		local ents = {}
		print(self.layout)
		print(type(self.ents))
		for k, ent in ipairs(self.ents) do
			local type, sprite, x, y, name = unpack(ent)
			ents[k] = _entity[type](sprite, x, y, name)
		end
		self.ents = nil
		return ents
	end
}

--dynamic tiles
class "dynTile" {
}
	