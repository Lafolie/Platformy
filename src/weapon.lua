--[[
	WEAPON
]]

class "weapon" {
	__init__ = function(self, bulletSpr, spawnOffsetX, spawnOffsetY, cool, spawnVelX, spawnVelY)
		self.bullet = {} --table of 'bullets' spawned by this weapon
		self.spawnOffsetX = spawnOffsetX or 0
		self.spawnOffsetY = spawnOffsetY or 0 --these cause the bullet to spawn in line with the users' sprite
		self.bulletSpr = bulletSpr or spriteset("spr/power.png", 4, 5)
		self.spawnVelX = spawnVelX or 150
		self.spawnVelY = spawnVelY or self.spawnVelX
		self.cool = cool or 0.15 --weapon cooldown
		self.time = love.timer.getTime()
	end,
	
	update = function(self, dt, t, map, offsetX, offsetY)
		for k, bullet in ipairs(self.bullet) do
			bullet:update(dt, t, map, offsetX, offsetY)
			if bullet.kill then table.remove(self.bullet, k) end
		end
	end,
	
	--no draw yet as weapons are included in the entity sprite
	--HOWEVER, it may be that case that I want to have weapons display whilst moving around... we'll see.
	draw = function(self)
		--somecode
	end,
	
	fire = function(self, t, posX, posY, velX, velY)
		if t - self.time >= self.cool then
			local newBullet = bullet(self.bulletSpr, posX + (self.spawnOffsetX * velX), posY + self.spawnOffsetY, self.spawnVelX * velX, self.spawnVelY * velY)
			table.insert(self.bullet, newBullet)
			self.time = t
			print("FIRE!")
		end
	end
}
		