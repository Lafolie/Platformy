--[[
	BULLET
	Not confined to actual ballistics, this class can be used for any type of damaging effect.
]]

class "bullet" (sprite) {
	__init__ = function(self, spriteset, posX, posY, velX, velY)
		sprite.__init__(self, spriteset, {stand = {{1, 0}}}, posX, posY)
		self.velX = velX or 0
		self.velY = velY or 0
	end,
	
	update = function(self, dt, t, map, offsetX, offsetY)
		self.posX = self.posX + self.velX * dt
		self.posY = self.posY + self.velY * dt
		
		local x, y =  math.ceil(self.posX / map.env.tileSize), math.ceil(self.posY / map.env.tileSize)
		x = math.max(math.min(x, # map.layout[y]), 1)
		y = math.max(math.min(y, # map.layout), 1)
		
		if map:pass(x, y) then
			self.kill = true
		end
		print("BULLET-" .. self.posX)
		sprite.update(self, dt, t, offsetX, offsetY)
	end,
	
	draw = function(self)
		sprite.draw(self)
	end
}