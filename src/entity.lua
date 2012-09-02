--[[
	ENTITY
	NPCs, items and anything else that exists in but isn't a part of a map.
]]

class "entity" (sprite) {
	__init__ = function(self, name, spriteset, animation, width, height, posX, posY)
		sprite.__init__(self, spriteset, animation, posX, posY)
		
		--unfinished bits
		self.name = name or "New Entity"
		self.posX = posX or 0
		self.posY = posY or 0
		self.hp = 99
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
	
	update = function(self, dt, t, map, offsetX, offsetY, check)
		--execute ai scripts
		if self.ai then
			self:ai()
		end
		
		if dt ~= 0 then
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
					local worldX, worldY = self:getWorld(-self.width / 4, -1, map.env.tileSize, map)
					local worldX2 = self:getWorld(self.width / 4, -1, map.env.tileSize, map)
					if not map:pass(worldX, worldY - 1) and not map:pass(worldX2, worldY - 1) then
						self.velY = self.jmpDisable and self.velY or self.jmp
						self.jmpDisable = true
					else
						self.control.jump = nil
					end
				end
				
				if self.control.jumpRelease then
					self.velY = math.max(-100, self.velY)
					self.jmpDisable = nil
				end
				
				if self.control.jumpRelease then
					self.control.jump = nil
					self.control.jumpRelease = nil
				end
			else
				self.control = {} --unable to move oneself, so remove voluntary responses
				if t - self.lockTime >= self.lockFree then
					self.controlLock = nil
					self.lockFree = nil
					self.lockTime = nil
				end
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
				if (map:pass(worldX, worldY) or 0) >= 2 then --and not(self.ramp) then
					if self.velX < 0 then
						self.velX = 0
						self.posX = (worldX * map.env.tileSize) + w
					end
					
				end
				if map:pass(worldX, worldY - 1) and (self.air or math.abs(self.velY) < 75) then
					if self.velX < 0 then
						self.velX = 0
						self.posX = (worldX * map.env.tileSize) + w
	
					end
				end
				
				--RIGHT SENSOR
				local worldX, worldY = self:getWorld(w + 1, h / 2, map.env.tileSize, map)
				if debugMode then
					self.dxdot = (worldX * map.env.tileSize)
				end
				if (map:pass(worldX, worldY) or 10) <= 2 then --and not(self.ramp) then --only collide if it's a true solid tile
					if self.velX > 0 then
						self.velX = 0
						self.posX = (worldX * map.env.tileSize) - (map.env.tileSize + w)
					end
				end
				if map:pass(worldX, worldY - 1) and (self.air or math.abs(self.velY) < 75) then
					if self.velX > 0 then
						self.velX = 0
						self.posX = (worldX * map.env.tileSize) - (map.env.tileSize + w)
	
					end
				end
				
				--gravitah (respect my)			
				--sensory
				local worldX, worldY = self:getWorld(-w * 0.25, h * 2 + 1, map.env.tileSize, map)
				local senA = map:pass(worldX, worldY)
				local worldX, worldY = self:getWorld(w * 0.25, h * 2 + 1, map.env.tileSize, map)
				local senB = map:pass(worldX, worldY)
							
				--actuate
				--local hmOffSet = map.env.tileSize + math.abs(hmB - hmA)
				
				if (not senA and not senB) or self.velY < 0 then
					--nothing
					self.velY = self.velY + map.env.gravity * dt
					self.air = true
				elseif (senA and senA == 2) or (senB and senB == 2) then
					--floor
					if self.velY >= 0 and self.posY + self.velY * dt >= worldY * map.env.tileSize then
						self.velY = 0
						self.posY = (worldY -2) * map.env.tileSize
						self.air = nil
					else
						self.velY = 0
						self.posY = (worldY - 2) * map.env.tileSize
						self.air = nil
					end
				elseif (senA and senA ~= 2) and (senB and senB ~= 2) then
					self.posY = (worldY - 1) * map.env.tileSize + 1
				end
				
				--special case for stairs
				local stairsOffsetX = self.direction == "right" and w * 0.25 or -w * 0.25
				local worldX, worldY = self:getWorld(stairsOffsetX, map.env.tileSize - 1, map.env.tileSize, map)
				if map:pass(worldX, worldY) and self.velY >= 0 then
					--stairs
					local worldX, worldY = self:getWorld(-w * 0.25, 10, map.env.tileSize, map)
					local hm = map:heightMap(worldX, worldY)
					local hmId = hm and math.floor((self.posX - w * 0.25) - (worldX - 1) * map.env.tileSize)
					local hmA = hm and hm[hmId] or 0
	
					local worldX, worldY = self:getWorld(w * 0.25, 10, map.env.tileSize, map)
					local hm = map:heightMap(worldX, worldY)
					local hmId = hm and math.floor((self.posX + w * 0.25) - (worldX - 1) * map.env.tileSize)
					local hmB = hm and hm[hmId] or 0
					self.hmA = hmA == 0 and hmA
					self.hmB = hmB == 0 and hmB
					--prevent snapping from above
					if self.air and self.posY < (worldY - 1) * map.env.tileSize - math.max(hmA, hmB) then
						self.velY = self.velY + map.env.gravity * dt
						self.air = true
--					elseif self.velY < 0 and self.posY - h * 2 > (worldY) * map.env.tileSize - math.min(hmA, hmB) then
--						self.posX = (worldX - 1) * map.env.tileSize - w
					else
						--set to height of ramp/stair
						if (hmA == 0 and hmB == 0) and self.velY > 0 then 
							--the magick fix
							--prevents the bug whereby the entity gets stuck on the corner of the block
							self.velY = self.velY + (2 * map.env.gravity) * dt
--						elseif (hmA == 0 and hmB == 1) or (hmA == 1 and hmB == 0) then
--							self.posY = self.posY + 1
						else
							self.posY = (worldY - 1) * map.env.tileSize - (hmA + hmB) / 2 --math.max(hmA, hmB)
							self.velY = 0 
							self.air = nil
							self.ramp = true
						end
					end
				else
					self.ramp = nil			
				end
	
				--celings
				if self.velY < 0 then
					local senC, senD = true, true --ground sensors
					
					local worldX, worldY = self:getWorld(-w / 4, -h * 2 - 1, map.env.tileSize, map)
					if map:pass(worldX, worldY) then
						senC = nil
					end
					
					local worldX, worldY = self:getWorld(w / 4, -h * 2 - 1, map.env.tileSize, map)
					if map:pass(worldX, worldY) then
						senD = nil
					end
					
					if senC and senD then
						--somecode
					elseif self.posY + self.velY < worldY * map.env.tileSize then
						self.velY = 0
						self.posY = (worldY	* map.env.tileSize) + map.env.tileSize + self.offsetY2
					end
					
					--special case for stairs ON THE CEILING (EXPERIMENTAL, DISABLED FOR NOW)
		--			local stairsOffsetX = self.direction == "right" and -w * 0.25 or w * 0.25
		--			local worldX, worldY = self:getWorld(stairsOffsetX, -map.env.tileSize + 1, map.env.tileSize, map)
		--			print("WX-" .. worldX)
		--			if (map:pass(worldX, worldY - 1) and self.velY <= 0) then
		--				--stairs
		--				local worldX, worldY = self:getWorld(-w * 0.25, -10, map.env.tileSize, map)
		--				local hm = map:heightMap(worldX, worldY)
		--				local hmId = hm and math.floor((self.posX - w * 0.25) - (worldX - 1) * map.env.tileSize)
		--				local hmA = hm and hm[hmId] or 0
		--
		--				local worldX, worldY = self:getWorld(w * 0.25, -10, map.env.tileSize, map)
		--				local hm = map:heightMap(worldX, worldY)
		--				local hmId = hm and math.floor((self.posX + w * 0.25) - (worldX - 1) * map.env.tileSize)
		--				local hmB = hm and hm[hmId] or 0
		--				<remove>
		--				prevent snapping from above
		--				if self.air and self.posY < (worldY - 1) * map.env.tileSize - math.max(hmA, hmB) then
		--					self.velY = self.velY + map.env.gravity * dt
		--					self.air = true
		--				elseif self.velY < 0 and self.posY - h * 2 > (worldY) * map.env.tileSize - math.min(hmA, hmB) then
		--					self.posX = (worldX - 1) * map.env.tileSize - w
		--					
		--				else
		--				</remove>
							--set to height of ramp/stair
		--					self.posY = (worldY - 1) * map.env.tileSize - math.max(hmA, hmB)
		--					self.velY = 0 
		--					print(math.max(hmA, hmB) .. " A-" .. hmA .. " B-" .. hmB .. " posY-" .. self.posY .. " wy" .. worldY)
		--					--self.air = nil
		--					--self.ramp = true
		--				--end
		--			else
		--				--self.ramp = nil
		--			end
	
				end
			end
			
			--vertical velocity limits
			if self.velY < 0 and self.velY < -1000 then self.velY = -1000 end
			if self.velY > 0 and self.velY > 1000 then self.velY = 1000 end
			
			--fire the weapon
			if self.control.fire and self.weapon then
				local bulletDirectionX = self.direction == "left" and -1 or 1
				self.control.fire = self.weapon:fire(t, self.posX, self.posY, bulletDirectionX, 0)
			end
			--update the weapon & bullets
			if self.weapon then
				if self.weapon.burst and not self.control.fire then self.weapon.burst = 0 end
				self.weapon:update(dt, t, map, offsetX, offsetY, check)
			end
		end--end dt check hack fix glitch bug crap stupid
		
		--finish up!
		if self.velX == 0 and not(self.air) then self:setAnim("stand") end
		if self.air and self.jmpDisable then self:setAnim("jump") end
		if self.air and not(self.jmpDisable) and math.abs(self.velY) > 85  then self:setAnim("stand") end
		
		self.posX = self.posX + self.velX * dt
		self.posY = self.posY + self.velY * dt
		
		--check for dead
		if self.hp <= 0 then
			self.kill = true
		end
		sprite.update(self, dt, t, offsetX, offsetY) --update graphics
	end,
	
	draw = function(self)
		--draw bullets
		if self.weapon then
			for k, bullet in ipairs(self.weapon.bullet) do
				bullet:draw()
			end
		end
		--draw self
		sprite.draw(self)
		love.graphics.setPointStyle("rough")
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.point(self.dxdot or 0, self.posY)
	end,
	
	lock = function(self, time)
		self.controlLock = true
		self.lockTime = love.timer.getTime()
		self.lockFree = time
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
		y = math.max(math.min(y, # map.layout[2]), 1)
		x = math.max(math.min(x, # map.layout[2][y]), 1)
		return x, y
	end		
}			