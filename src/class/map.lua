--[[
	MAP
	Map data structure.
]]

class "map" {
	__init__ = function(self, data)
		local layout, tileset, dynamic, environment, name, ents = unpack(data)
		self.layout = layout
		self.mapEnt = dynamic or {} --holds dynamic tiles
		self.ents = ents or {}
		self.tileset = cache.tileset(tileset)
		self.name = name or "Untitled Area"
		self.posX = 0
		self.posY = 0
		self.env = environment or {friction = 1000, gravity = 600, tileSize = 16, oc = 2}
		self.env.background = self.env.background and cache.image(self.env.background)
		--determine width and height
		self.width = # layout[self.env.oc][1]
		self.height = # layout[self.env.oc]
		assert(self.width >= platformy._res.width / environment.tileSize, "Minimum map width is " .. platformy._res.width / environment.tileSize .. "!")
		assert(self.height >= platformy._res.height / environment.tileSize, "Minimum map height is " .. platformy._res.height / environment.tileSize .. "!")
		
		self.batch = {}
--		self.offsetX = love.graphics.getWidth()
--		self.offsetY = love.graphics.getHeight()
		self.offsetX = 0
		self.offsetY = 0
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
		for k, mapEnt in ipairs(self.mapEnt) do
			if mapEnt.load then mapEnt:load() end
		end
		
		local renderTime = love.timer.getMicroTime() - renderTime
		print("\tCompile time: " .. renderTime .. "s")
		print("\tAnimated tiles: " .. # self.animatedTiles)
		
	end,
	
	update = function(self, dt, t, offsetX, offsetY)
		for k, id in ipairs(self.animatedTiles) do
			--animation function
		end
		
		for k, mapEnt in ipairs(self.mapEnt) do
			mapEnt:update(dt, t, offsetX, offsetY)
		end
		
	end,
	
	draw = function(self, layer)
		local layer = layer or 2
		if layer == 2 then
			for k, mapEnt in ipairs(self.mapEnt) do
				mapEnt:draw()
			end
		end
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(self.batch[layer], self.posX + self.offsetX, self.posY + self.offsetY)
	end,
	
	--return only the passibility of a tile
	pass = function(self, x, y)
		if y <= 0 or y > # self.layout[self.env.oc] then return nil end
		if x <= 0 or x > # self.layout[self.env.oc][y] then return nil end
		return self.tileset.tile[self.layout[self.env.oc][y][x]].property.pass--return passability property of xy
	end,
	
	--return the properties of a tile
	properties = function(self, x, y)
		if y <= 0 or y > # self.layout[self.env.oc] then return nil end
		if x <= 0 or x > # self.layout[self.env.oc][y] then return nil end
		
		local tile = self.tileset.tile[self.layout[self.env.oc][y][x]].property
		--check for collision functions
		if self.target then
			--damage
			if tile.damage then
				self.target:damage(tile.damage)
			end
		end
		
		return tile  --return tile properties
	end,
	
	--get entites from initial map load (should executed once by map handler)
	getEnts = function(self)
		local ents = {}
		for k, ent in ipairs(self.ents) do
			ents[k] = _entity[ent.type](ent.sprite, ent.posX, ent.posY, ent.name)
		end
		self.ents = nil
		return ents
	end,
	
	--focus operations on a particular entity
	imprint = function(self, entity)
		self.target = entity
	end,
	
	--clear the data set by imprinting
	clear = function(self)
		self.target = nil
	end
}

--dynamic tiles
class "mapEnt" (sprite) {
	__init__ = function(self, data)
		local spriteset, posX, posY, accel, velX, velY = unpack(data)
		sprite.__init__(self, spriteset, posX, posY)
		self.posX = posX or 0
		self.posY = posY or 0
		self.accel = accel or 1000
		self.maxVelX = velX or 100
		self.maxVelY = velY or 100
	end,
	
	update = function(dt, t, offsetX, offsetY)
		sprite.update(self, dt, t, offsetX, offsetY)
	end,
	
	draw = function()
		sprite.draw(self)
	end
}

--load custom mapEnts
_mapEnt = {}
local ents = love.filesystem.enumerate("mapEnt")
for k, ent in ipairs(ents) do
	--ignore hidden files
	if not (ent:sub(1, 1) == ".") then
		love.filesystem.load("mapEnt/" .. ent)()
	end
end
	