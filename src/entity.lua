--[[
	ENTITY
	NPCs, items and anything else that exists in but isn't a part of a map.
]]

class "entity" (sprite) {
	__init__ = function(self, spriteset)
		sprite.__init__(self, spriteset, width, height)
		
		--unfinished bits
		self.control = {}
		self.velX = 0 --horizontal velocity
		self.maxVelX = 100 --max x velocity
		self.velY = 0 --vertical velocity
		self.maxVelY = 100 --max y velocity
		self.accel = 1000 --horizontal acceleration
		self.decel = 1000 --horizontal deceleration
		self.airAc = 2000
		self.jmp = -250 --vertical acceleration
		
		self.width = width or 16
		self.height = height or self.width --these are used for collisions
	end,
	
	update = function(self, dt, t, map)
		--badass pseudo physics (all hail Yuji Naka)
		if not(self.controlLock) then
			--apply voluntary movement
			if self.control.left then
				--check for same direction and adjust accordingly
				self.velX = self.velX <= 0 and math.max(self.velX - self.accel * dt, -self.maxVelX) or self.velX - self.decel * dt
				if self.velX < 0 then 
					self.direction = "left"
					self:setAnim("run")
				end
	
			end
			if self.control.right then
				--check for same direction and adjust accordingly
				self.velX = self.velX >= 0 and math.min(self.velX + self.accel * dt, self.maxVelX) or self.velX + self.decel * dt
				if self.velX > 0 then
					self.direction = "right"
					self:setAnim("run")
				end
			end
			
			--jumping
			if self.control.jump and not(self.air) then
				self.velY = self.jmpDisable and self.velY or self.jmp
				self.jmpDisable = true
			end
			
			if self.control.jumpRelease then
				self.velY = math.max(-100, self.velY)
				self.jmpDisable = false
			end
			
			if self.control.jump and self.control.jumpRelease then
				self.control.jump = nil
				self.control.jumpRelease = nil
			end
		else
			self.control = {} --unable to move oneself, so remove voluntary responses
		end
		
		if not(self.control.left) and not(self.control.right) then
			--apply friction
			if self.velX < 0 then
				self.velX = math.abs(self.velX) > map.env.friction * dt and self.velX + map.env.friction * dt or 0
			elseif self.velX > 0 then
				self.velX = self.velX > map.env.friction * dt and self.velX - map.env.friction * dt or 0
			end
		end
		
		--do the collision ting
		if not(self.noclip) then
			local w = math.floor(self.width / 2)
			local h = math.floor(self.height / 2) --halved since the sprite is centred
						
			--LEFT SENSOR
			local worldX, worldY = self:getWorld(-w - 1, h / 2, map.env.tileSize, map)
			--debug
			if debugMode then
				self.dxdot = (worldX * map.env.tileSize)
			end
			--/debug 
			if (map:pass(worldX, worldY) or 0) >= 2 and not(self.ramp) then
				if self.velX < 0 then
					self.velX = 0
					self.posX = (worldX * map.env.tileSize) + w
				end
				
			end
			if map:pass(worldX, worldY - 1) and (not(self.air) or math.abs(self.velY) < 75) then
				if self.velX < 0 then
					self.velX = 0
				end
				self.posX = (worldX * map.env.tileSize) + w
			end
			
			--RIGHT SENSOR
			local worldX, worldY = self:getWorld(w + 1, h / 2, map.env.tileSize, map)
			if debugMode then
				self.dxdot = (worldX * map.env.tileSize)
			end
			if (map:pass(worldX, worldY) or 10) <= 2 and not(self.ramp) then --only collide if it's a true solid tile
				if self.velX > 0 then
					self.velX = 0
					self.posX = (worldX * map.env.tileSize) - (map.env.tileSize + w)
				end
				
				--check for stairs(right)
--				
			end
			if map:pass(worldX, worldY - 1) and (not(self.air) or math.abs(self.velY) < 75) then
				if self.velX > 0 then
					self.velX = 0
				end
				self.posX = (worldX * map.env.tileSize) - (map.env.tileSize + w)
			end
			
			--gravitah (respect my)
			--local senA, senB = true, true --ground sensors
			
			--sensory
			local worldX, worldY = self:getWorld(-w * 0.25, map.env.tileSize + 1, map.env.tileSize, map)
--			if map:pass(worldX, worldY) == 2 then
--				senA = nil
--			end
			local senA = map:pass(worldX, worldY)
			local worldX, worldY = self:getWorld(w * 0.25, map.env.tileSize + 1, map.env.tileSize, map)
--			if map:pass(worldX, worldY) == 2 then
--				senB = nil
--			end
			
			local senB = map:pass(worldX, worldY)
						
			--actuate
			--local hmOffSet = map.env.tileSize + math.abs(hmB - hmA)
			
			if (not(senA) and not(senB)) or self.velY < 0 then
				--nothing
				self.velY = self.velY + map.env.gravity * dt
				self.air = true
			elseif (senA == 2) or (senB == 2) then
				--floor
				if self.velY >= 0 and self.posY + self.velY >= worldY * map.env.tileSize then
					self.velY = 0
						self.posY = (worldY * map.env.tileSize - map.env.tileSize) - map.env.tileSize
					
					self.air = nil
				else
					self.velY = 0
					self.posY = (worldY * map.env.tileSize - map.env.tileSize) - map.env.tileSize
					self.air = nil
				end
			elseif (senA ~=2) or (senB ~= 2) then
				self.posY = (worldY - 1) * map.env.tileSize + 1
			end
			
			--special case for stairs
			local worldX, worldY = self:getWorld(1, 15, map.env.tileSize, map)
			if (map:pass(worldX, worldY) and self.velY >= 0) or self.stairs then
				--stairs
				self.air = nil
				self.ramp = true
				local worldX, worldY = self:getWorld(-w * 0.5, 10, map.env.tileSize, map)
				local hm = map:heightMap(worldX, worldY)
				local hmId = hm and math.floor((self.posX - w * 0.25) - (worldX - 1) * map.env.tileSize)
				local hmA = hm and hm[hmId] or 0

				local worldX, worldY = self:getWorld(w * 0.5, 10, map.env.tileSize, map)
				local hm = map:heightMap(worldX, worldY)
				local hmId = hm and math.floor((self.posX + w * 0.25) - (worldX - 1) * map.env.tileSize)
				local hmB = hm and hm[hmId] or 0
				self.posY = (worldY - 1) * map.env.tileSize - math.max(hmA, hmB)
				self.velY = 0 
				print((hmA + hmB) / 2 .. " A-" .. hmA .. " B-" .. hmB .. " hmID-" .. 1 .. " wy" .. worldY)
			else
				self.ramp = nil
			end
			
						--special case for stairs
--			if (senA and senA ~= 2) and (senB and senB ~= 2) then
--				local worldX, worldY = self:getWorld(0, 20, map.env.tileSize, map)
--				local hm = map:heightMap(worldX, worldY)
--				local hmId = hm and math.floor((self.posX - w * 0.25) - (worldX * map.env.tileSize - 16))
--				local hmA = hm and hm[hmId] or 16
--				print(hmId)
--				
--				local worldX, worldY = self:getWorld(0, 20, map.env.tileSize, map)
--				local hm = map:heightMap(worldX, worldY)
--				local hmId = hm and math.floor((self.posX + w * 0.25) - (worldX * map.env.tileSize - 16))
--				local hmB = hm and hm[hmId] or 16
--				self.posY = self.posY - (hmA + hmB) / 2
--				print(hmId)
--			end
			--celings
			if self.air then
				local worldX, worldY = self:getWorld(-w / 4, -map.env.tileSize + 1, map.env.tileSize, map)
				local senC, senD = true, true --ground sensors
				
				if map:pass(worldX, worldY) then
					senC = nil
				end
				
				local worldX, worldY = self:getWorld(w / 4, -map.env.tileSize + 1, map.env.tileSize, map)
				if map:pass(worldX, worldY) then
					senD = nil
				end
				
				if senC and senD then
					--somecode
				elseif self.posY + self.velY < worldY * map.env.tileSize then
					self.velY = 0
					self.posY = (worldY	* map.env.tileSize) + map.env.tileSize - h * 0.25
				end
			end
				
		end
		
		--finish up!
		if self.velX == 0 and not(self.air) then self:setAnim("stand") end
		if self.air and self.jmpDisable then self:setAnim("jump") end
		if self.air and not(self.jmpDisable) and math.abs(self.velY) > 75  then self:setAnim("stand") end
		
		self.posX = self.posX + self.velX * dt
		self.posY = self.posY + self.velY * dt
		sprite.update(self, dt, t) --update graphics
	end,
	
	draw = function(self, offsetX, offsetY)
		sprite.draw(self, offsetX, offsetY)
		love.graphics.setPointStyle("rough")
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.point(self.dxdot or 0, self.posY)
	end,
	
	--This is more compact:
	collide = function(x1,y1,w1,h1, x2,y2,w2,h2)
		return not (x1+w1 < x2  or x2+w2 < x1 or y1+h1 < y2 or y2+h2 < y1)
	end,

	--And this one works for a single point inside a box:
	collidePoint = function(x1,y1, x2,y2,w2,h2)
		return not (x1 < x2  or x2+w2 < x1 or y1 < y2 or y2+h2 < y1)
	end,
	
	--And you can use this one to find collisions of a single point with a circle: (By checking if the distance is less than the radius of the circle)
	collideDistance = function(x1,y1,x2,y2) 
		return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) 
	end,
	
	getWorld = function(self, offX, offY, tileSize, map)
		local x, y =  math.ceil((self.posX + offX) / tileSize), math.ceil((self.posY + offY) / tileSize)
		x = math.max(math.min(x, # map.layout[1]), 1)
		y = math.max(math.min(y, # map.layout), 1)
		return x, y
	end		
}			