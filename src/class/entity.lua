--[[
	ENTITY
	Characters, items and anything else that exists in but isn't a part of a map.
	Handles movement, collision, AI and other actions.
	Collision is based on sizes that should correspond to the sprite and tile grid size.
]]

class "entity" (sprite) {
	__init__ = function(self, name, spriteset, animation, width, height, posX, posY)
		sprite.__init__(self, spriteset, posX, posY)
		
		--unfinished bits
		self.name = name or "New Entity"
		self.posX = posX or 0
		self.posY = posY or 0
		self.hp = 99
		self.control = {}
		self.velX = 0 --horizontal velocity
		self.maxVelX = 115 --max x velocity
		self.velY = 0 --vertical velocity
		self.maxVelY = 100 --max y velocity
		self.accel = 1000 --horizontal acceleration
		self.decel = 1000 --horizontal deceleration
		self.airAc = 2000
		self.jmp = -300 --vertical acceleration
		
		self.width = width or 16
		self.height = height or self.width --these are used for collisions
		
		--setup sensors
		local w = self.width / 2
		local h = self.height / 2
		
		self.jumpSensorL = {-w / 2, -1, 0, -1}
		self.jumpSensorR = {w / 2, -1, 0, -1}
		
		self.lowerSensorL = {-w - 1, h / 2, 0, 0}
		self.upperSensorL = {-w - 1, h / 2, 0, -1}
		self.lowerSensorR = {w + 1, h / 2, 0, 0}
		self.upperSensorR = {w + 1, h / 2, 0, -1}
		
		self.floorSensorL = {-w + 4, h * 2 + 1, 0, 0}
		self.floorSensorR = {w - 4, h * 2 + 1, 0, 0}
		
		self.rampSensor = {0, 15, 0, 0}
		self.rampSensorL = {-w / 4, h + 1, 0, 0}
		self.rampSensorR = {w / 4, h + 1, 0, 0}
		
		self.ceilSensorL = {-w / 4, -h * 2 - 1, 0, 0}
		self.ceilSensorR = {w / 4, -h * 2 - 1, 0, 0}
	end,
	
	
	
	
	update = function(self, dt, t, map, offsetX, offsetY, check)
		--execute ai scripts
		if self.ai then
			self:ai()
		end
		
		--badass pseudo physics (all hail Yuji Naka)
		if dt ~= 0 then
			
			--width and height aliases (halved since sprites are centered)
			local w = self.width / 2
			local h = self.height / 2
			
			--update sensors
			local jumpSensorL = self:sensor(self.jumpSensorL, map)
			local jumpSensorR = self:sensor(self.jumpSensorR, map)
			
			local lowerSensorL = self:sensor(self.lowerSensorL, map)
			local upperSensorL = self:sensor(self.upperSensorL, map)
			local lowerSensorR = self:sensor(self.lowerSensorR, map)
			local upperSensorR = self:sensor(self.upperSensorR, map)
			
			local floorSensorL = self:sensor(self.floorSensorL, map)
			local floorSensorR = self:sensor(self.floorSensorR, map)
			
			local ceilSensorL = self:sensor(self.ceilSensorL, map)
			local ceilSensorR = self:sensor(self.ceilSensorR, map)
			
			--only move if control is enabled
			if not(self.controlLock) then
				--apply voluntary movement
				if self.control.left then
					--check for same direction and adjust accordingly
					self.velX = self.velX <= 0 and math.max(self.velX - self.accel * dt, -self.maxVelX) or self.velX - self.decel * dt
					if self.velX < 0 then 
						self.direction = "left"
					end
		
				end
				if self.control.right then
					--check for same direction and adjust accordingly
					self.velX = self.velX >= 0 and math.min(self.velX + self.accel * dt, self.maxVelX) or self.velX + self.decel * dt
					if self.velX > 0 then
						self.direction = "right"
					end
				end
				
				--jumping
				if self.control.jump and not(self.air) then
					--check for immediate ceiling
					if not jumpSensorL.pass and not jumpSensorR.pass then
						self.velY = self.jmpDisable and self.velY or self.jmp
						self.jmpDisable = true
					else
						self.control.jump = nil --prevents jump key being held down to jump when possible
					end
				end
				
				--stop jumping
				if self.control.jumpRelease then
					self.velY = math.max(-100, self.velY)
					self.jmpDisable = nil
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
							
				--LEFT SENSOR
				if (lowerSensorL.pass or 0) >= 2 then
					if self.velX < 0 then
						self.velX = 0
					end
					self.posX = lowerSensorL.posX + w
					
					--check for wall jump
					if (self.air and not self.jmpDisable) and self.control.jumpPress and self.control.right and not self.control.left then
						self.jmpDisable = true
						self.wallJump = true
						self.wallTime = t
						self:lock(0.05)
						self.velX = 0
					end
				end
				if upperSensorL.pass and (self.air or math.abs(self.velY) < 75) then
					if self.velX < 0 then
						self.velX = 0
					end
					self.posX = lowerSensorL.posX + w
				end
				
				--RIGHT SENSOR
				if (lowerSensorR.pass or 10) <= 2 then
					if self.velX > 0 then
						self.velX = 0
					end
					self.posX = lowerSensorR.posX - (map.env.tileSize + w)
					
					--check for wall jump
					if (self.air and not self.jmpDisable) and self.control.jumpPress and self.control.left and not self.control.right then
						self.jmpDisable = true
						self.wallJump = true
						self.wallTime = t
						self:lock(0.05)
						self.velX = 0
					end
				end
				if upperSensorR.pass and (self.air or math.abs(self.velY) < 75) then
					if self.velX > 0 then
						self.velX = 0
					end
					self.posX = upperSensorR.posX - (map.env.tileSize + w)
				end
				
				--gravitah (respect my)			
				if (not floorSensorL.pass and not floorSensorR.pass) or self.velY < 0 then
					--nothing
					self.velY = self.velY + map.env.gravity * dt
					self.air = true
				elseif (floorSensorL.pass and floorSensorL.pass == 2) or (floorSensorR.pass and floorSensorR.pass == 2) then
					--floor
					if self.velY >= 0 and self.posY + self.velY * dt >= floorSensorL.posY then
						self.velY = 0
						self.posY = floorSensorL.posY - map.env.tileSize * 2
						self.air = nil
					else
						self.velY = 0
						self.posY = floorSensorL.posY - map.env.tileSize * 2
						self.air = nil
					end
				elseif (floorSensorL.pass and floorSensorL.pass ~= 2) and (floorSensorR.pass and floorSensorR.pass ~= 2) then
					self.posY = floorSensorL.posY - map.env.tileSize + 1
				end
				
				--special case for stairs (do the sensor stuff here to prevent glitches)
				local stairsOffsetX = self.direction == "right" and -w * 0.25 or w * 0.25
				self.rampSensor[1] = stairsOffsetX
				local rampSensor = self:sensor(self.rampSensor, map)
				
				if rampSensor.pass and self.velY >= 0 then
					--stairs
					local rampSensorL = self:sensor(self.rampSensorL, map)
					local hmId = math.floor((self.posX - w / 4) - rampSensorL.posX + map.env.tileSize)
					local hmA = rampSensorL.prop.heightMap and rampSensorL.prop.heightMap[hmId] or 0
					
					local rampSensorR = self:sensor(self.rampSensorR, map)
					local hmId = math.floor((self.posX + w / 4) - rampSensorR.posX + map.env.tileSize)
					local hmB = rampSensorR.prop.heightMap and rampSensorR.prop.heightMap[hmId] or 0
					
					self.hmA = hmA --debug
					self.hmB = hmB --debug
					--prevent snapping from above
					if self.air and self.posY < rampSensorR.posY - map.env.tileSize - math.max(hmA, hmB) then
						self.velY = self.velY + map.env.gravity * dt
						self.air = true
--					elseif self.velY < 0 and self.posY - h * 2 > (worldY) * map.env.tileSize - math.min(hmA, hmB) then --can't remember what this line is for
--						self.posX = (worldX - 1) * map.env.tileSize - w
					else
						--set to height of ramp/stair
						if (hmA == 0 and hmB == 0) and self.velY > 0 then 
							--prevents the bug whereby the entity gets stuck on the corner of the block
							self.velY = self.velY + (2 * map.env.gravity) * dt
						else
							self.posY = rampSensorR.posY - map.env.tileSize - (hmA + hmB) / 2 --math.max(hmA, hmB)
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
					if ceilSensorL.pass and ceilSensorR.pass then
						if self.posY + self.velY < ceilSensorL.posY then
							self.velY = 0
							self.posY = ceilSensorL.posY + map.env.tileSize + self.offsetY2
						end
					end
					--place ramp ceiling code here
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
		end--end dt check hack fix glitch bug crap stupid
		
		--update the weapon & bullets
			if self.weapon then
				if self.weapon.burst and not self.control.fire then self.weapon.burst = 0 end
				self.weapon:update(dt, t, map, offsetX, offsetY, check)
			end
		--finish up!
		--set animations
		--special stuff for wall jumping
		if self.wallJump then
			self:setAnim("wall")
			self.velY = 0
			if t - self.wallTime > 0.05 then
				self.wallJump = nil
				self.velY = self.jmp * 0.9
				if self.direction == "right" then self.velX = self.maxVelX else self.velX = -self.maxVelX end
				self:lock(0.002) --lock control to prevent cancelling some x movement
			end
		else
			--running
			if not self.air and (self.control.left or self.control.right) then self:setAnim("run") end
			--standing still
			if self.velX == 0 and not(self.air) then self:setAnim("stand") end
			--jumping
			if self.air and self.jmpDisable then self:setAnim("jump") end
			--falling
			if self.air and not(self.jmpDisable) and math.abs(self.velY) > 85  then self:setAnim("jump") end
		end
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
		
		--debug stuff--------------------------------------
		if debugMode then
			love.graphics.setLineStyle("rough")
			love.graphics.setColor(255, 100, 25, 150)
			love.graphics.line(self.drawX + self.width, 0, self.drawX + self.width, love.graphics.getHeight())
			love.graphics.line(0, self.drawY + self.height, love.graphics.getWidth(), self.drawY + self.height)
			love.graphics.setColor(255, 255, 25, 150)
			love.graphics.line(self.drawX, 0, self.drawX, love.graphics.getHeight())
			love.graphics.line(0, self.drawY, love.graphics.getWidth(), self.drawY)
		end
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
	
	--retrieve tile data for collisions and such. off* = pixel offsets, off*2 = tile offsets
	sensor = function(self, sensorMap, map)
		local offX, offY, offX2, offY2 = unpack(sensorMap) --get the sensor mappings
		local x, y =  math.ceil((self.posX + offX) / map.env.tileSize), math.ceil((self.posY + offY) / map.env.tileSize) --convert to 'world' coords
		y = math.max(math.min(y, map.height), 1)
		x = math.max(math.min(x, map.width), 1)
		return {posX = x * map.env.tileSize, posY = y * map.env.tileSize, pass = map:pass(x + offX2, y + offY2), prop = map:properties(x + offX2, y + offY2)}
	end
}

--load custom entities
_entity = {}
local ents = love.filesystem.enumerate("entity")
for k, ent in ipairs(ents) do
	--ignore hidden files
	if not (ent:sub(1, 1) == ".") then
		love.filesystem.load("entity/" .. ent)()
	end
end