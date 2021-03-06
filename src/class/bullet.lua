--[[
	BULLET
	Not confined to actual ballistics, this class can be used for any type of damaging effect.
]]

class "bullet" (sprite) {
	__init__ = function(self, spriteset, posX, posY, velX, velY, damage, direction)
		sprite.__init__(self, spriteset, posX, posY)
		self.velX = velX or 0
		self.velY = velY or 0
		self.damage = damage
		self.direction = direction or "right"
		self.hp = 1
		self.afterImage.frame = 2
		self.afterImage.count = 0.05
	end,
	
	update = function(self, dt, t, map, offsetX, offsetY, check)
		if self.gravity then
			self.velY = self.velY + map.env.gravity * dt
		end
		self.posX = self.posX + self.velX * dt
		self.posY = self.posY + self.velY * dt
		
		local x, y =  math.ceil(self.posX / map.env.tileSize), math.ceil(self.posY / map.env.tileSize)
		local oc = map.env.oc
		y = math.max(math.min(y, # map.layout[oc]), 1)
		x = math.max(math.min(x, # map.layout[oc][y]), 1)
		
		--check for collisions with entities
		for k, entity in ipairs(check) do
			if entity.collidePoint(self.posX, self.posY, entity.posX - entity.width, entity.posY - entity.height, entity.width * 2, entity.height * 2) then
				entity:damage(self.damage, 0.25, self.velX)
				self.kill = true
			end
		end
		--hit a wall
		if map:pass(x, y) then
			self.kill = true
		end
		sprite.update(self, dt, t, offsetX, offsetY)
	end,
	
	draw = function(self)
		sprite.draw(self)
	end
}