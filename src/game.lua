--[[
	PLATFORMY
	Copyright (c) 2012 Dale James
	
	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
		
		The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

--[[
	GAME CLASS
]]

class "game" {
	__init__ = function(self)
		--Core stuff
		self.scale = 2
		love.graphics.setDefaultImageFilter("nearest", "nearest")
		self.saveGame = {progress = {}, items = {}, energy = 99, missile = 0, location = {0, 0}}
		self.mode = "map"
		self.key = {up = "w", down = "s", left = "a", right = "d", jump = "/", fire = "."}
		self.offsetX = (love.graphics.getWidth() / 2) / 2
		self.offsetY = (love.graphics.getHeight() / 2) / 2
		love.graphics.setIcon(love.graphics.newImage("spr/bleep.png"))

		--Graphic content
		self.entity = {}
		self.library = {}
		self.sprite = {}
		self.smoothIndex = 1
		self.smoothFactor = 4
		self.smooth = {}
		--local layout = {{6, 0, 18, 32}, {29, 1, 20, 31}, {52, 1, 22, 31}, {75, 1, 24, 31}}
		--TEMPORARY SAMUS
		local saxAnim = {stand = {{1, 0}}, run = {{3, 0.075}, {4, 0.075}, {5, 0.075}, {6, 0.075}, {7, 0.075}, {8, 0.075}, {9, 0.075}, {10, 0.075}, {11, 0.075}, {12, 0.075}}, jump = {{13, 0}}}
		self.sprite.samus = entity("Samus", spriteset("spr/saxSamus.png", 31, 37), saxAnim)
		self.sprite.samus.posX = 112
		self.sprite.samus.posY = 32
		self.sprite.samus.weapon = weapon(spriteset("spr/power.png", 4, 5), 8, -2, 33, 0.1, "semi")
--		self.sprite.samus.color = {255, 255, 255, 0}
		
		--TEMPORARY SAX
		self.spawnTime = love.timer.getTime()
		table.insert(self.entity, entity("SA-X", spriteset("spr/samus.png", 25, 32)))
		self.entity[1].posX = 102
		self.entity[1].posY = 32
		self.entity[1].color = {255, 100, 255, 255}
		self.entity[1].control.right = true
		self.entity[1].ai = function(self)
			if self.velX == 0 then
				self.control.jump = true
				if self.velY > 90 then self.control.jumpRelease = true end
				if self.velY > 0 and self.control.jumpRelease then
					if self.control.left then 
						self.control.left = nil
						self.control.right = true
					else
						self.control.left = true
						self.control.right = nil
					end
				end
			else
--				self.control.jumpRelease = nil
			end
--			if (self.control[direction] == true and self.velY > 0 then
				
		end
			 
		
		--TEMP DATA, to be stored in files eventually
		self.environment = {}
		self.environment.friction = 750
		self.environment.gravity = 600
		self.environment.tileSize = 16
		
		local clip = tileProperties(2)
		local noclip = tileProperties()
		local basicRamp = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}
		local basicRamp2 = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1}
		local ramp = tileProperties(3, basicRamp)
		local ramp2 = tileProperties(1, basicRamp2)
		local properties = {
							noclip, noclip, noclip, noclip, clip, clip,
							noclip, clip, clip, clip, noclip, noclip,
							clip, clip, clip, clip, noclip, clip,
							clip, clip, clip, clip, noclip, noclip,
							clip, noclip, ramp, ramp2, clip, clip,
							clip, clip, clip, clip, clip, clip
							} --load tileset passabilty data
		local tempunderlay = {
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 23, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
		}
		
		
		local tempmap = {
							{15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15},
							{15, 6, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 5, 15},
							{15, 16, 17, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 14, 15},
							{15, 16, 17, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 14, 15, 15},
							{15, 16, 17, 1, 1, 1, 1, 1, 24, 23, 1, 12, 1, 1, 1, 1, 1, 1, 20, 21, 21, 21, 21, 21, 21, 21, 6},
							{15, 16, 17, 1, 35, 1, 35, 1, 30, 36, 36, 18, 1, 1, 1, 1, 1, 1, 26, 1, 1, 1, 1, 1, 1, 1, 14},
							{15, 16, 17, 1, 35, 1, 35, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 14},
							{15, 16, 17, 1, 35, 1, 35, 1, 1, 1, 1, 1, 1, 1, 24, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 3, 14},
							{15, 16, 17, 1, 30, 36, 18, 1, 1, 1, 1, 1, 1, 1, 30, 36, 36, 36, 9, 9, 9, 9, 9, 9, 9, 9, 5},
							{15, 16, 17, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 14, 15},
							{15, 16, 17, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 14, 15},
							{15, 16, 17, 1, 1, 1, 1, 1, 1, 27, 10, 11, 1, 1, 1, 1, 1, 1, 14, 15},
							{15, 5, 28, 3, 3, 3, 3, 3, 27, 33, 16, 28, 3, 3, 3, 3, 3, 27, 6, 15},
							{15, 15, 34, 9, 9, 9, 9, 9, 33, 6, 15, 34, 9, 9, 9, 9, 9, 33, 15, 15},
							{15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15}
						}
		local tempoverlay = {
								{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 17, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 14, 1},
							{1, 1, 17, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 14, 1, 1},
							{1, 1, 17, 1, 1, 1, 1, 1, 24, 1, 23, 12, 1, 1, 1, 1, 1, 1, 20, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 17, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, },
							{1, 1, 17, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 17, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 24, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 3, 3},
							{1, 1, 17, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 17, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 14, 1},
							{1, 1, 17, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 14, 1},
							{1, 1, 17, 1, 1, 1, 1, 1, 1, 27, 10, 1, 1, 1, 1, 1, 1, 1, 14, 1},
							{1, 1, 28, 3, 3, 3, 3, 3, 27, 1, 1, 28, 3, 3, 3, 3, 3, 27, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
							{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
							}
		self.tmap = map({tempunderlay, tempmap, {}}, tileset("spr/zeroTiles.png", properties, self.environment.tileSize), self.environment, "Wyvern Rock")
		
		--Game content
		self.overworld = {}
		self.tempbackground = love.graphics.newImage("spr/bgtemp.png")
		
	end,
	
	update = function(self, dt)
		--Core variables and surch
		local t = love.timer.getTime()
		
		if self.mode == "map" then
			--Temp stuff
			if love.keyboard.isDown(self.key.left) then self.sprite.samus.control.left = true else self.sprite.samus.control.left = nil end
			if love.keyboard.isDown(self.key.right) then self.sprite.samus.control.right = true else self.sprite.samus.control.right = nil end
			
			--player2test
			self.tmap:update(dt, t)
			--update player
			for k, sprite in pairs(self.sprite) do
				sprite:update(dt, t, self.tmap, -self.sprite.samus.posX + self.offsetX, -self.sprite.samus.posY + self.offsetY, self.entity)
			end
			--smoothing factor. Used to smooth out the scrolling effect
			self.smooth[self.smoothIndex] = {}
			self.smooth[self.smoothIndex].x = -self.sprite.samus.posX
			self.smooth[self.smoothIndex].y = -self.sprite.samus.posY
			
			local smoothOffset = {x = 0, y = 0}
			for k, pos in ipairs(self.smooth) do
				smoothOffset.x = smoothOffset.x + pos.x
				smoothOffset.y = smoothOffset.y + pos.y
			end
			
			smoothOffset.x = (smoothOffset.x / # self.smooth)
			smoothOffset.y = (smoothOffset.y / # self.smooth)
			
			self.smoothIndex = self.smoothIndex + 1 <= self.smoothFactor and self.smoothIndex + 1 or 1
--			smoothOffset.x = 0
--			smoothOffset.y = 0
			--spawn stuff
			if # self.entity < 1 and t - self.spawnTime > 2.5 then
				self.spawnTime = t
				table.insert(self.entity, entity("SA-X", spriteset("spr/samus.png", 25, 32), nil, 16, 16, 102, 32))
				local newDirection = "right"
				if # self.entity % 2 == 0 then
					newDirection = "left"
				end
				self.entity[# self.entity].control[newDirection] = true
				self.entity[# self.entity].color = {255, 100, 255, 255}
				self.entity[# self.entity].weapon = weapon(spriteset("spr/power.png", 4, 5), 8, -6, 33, 0.1)
				self.entity[# self.entity].control.fire = true
				self.entity[# self.entity].ai = function(self)
					local toggleDirection = function()
						if self.control.left then 
							self.control.left = nil
							self.control.right = true
						else
							self.control.left = true
							self.control.right = nil
						end
					end
					if self.velX == 0 then
						self.control.jump = true
						if self.velY > 75 then self.control.jumpRelease = true end
						if (self.velX == 0 and self.control.jumpRelease) then
							toggleDirection()
						elseif not self.air then
							--toggleDirection()
						end
					end
					if self.velY == 0 and self.velX == 0 then
						--toggleDirection()
					end
				end
			end

			--update player BARTBES HACK
			for k, sprite in pairs(self.sprite) do
				sprite:update(0, t, self.tmap, -self.sprite.samus.posX + self.offsetX, -self.sprite.samus.posY + self.offsetY, self.entity)
			end
			--update entities
			for k = #self.entity, 1, -1 do
				local entity = self.entity[k]
				entity:update(dt, t, self.tmap, smoothOffset.x + self.offsetX, smoothOffset.y + self.offsetY, self.entity)
				if entity.kill then 
					table.remove(self.entity, k) 
				end
			end
			
			--update the drawing position of the map
			self.tmap.offsetX = smoothOffset.x + self.offsetX
			self.tmap.offsetY = smoothOffset.y + self.offsetY
		end
	end,
	
	draw = function(self)
		love.graphics.push()
		love.graphics.scale(self.scale)
		love.graphics.draw(self.tempbackground, 0, 0)
		self.tmap:draw(1)
		for k, sprite in pairs(self.sprite) do
			sprite:draw()
--			love.graphics.line(0, self.sprite.samus.drawY - 1, 320, self.sprite.samus.drawY - 1)
			--love.graphics.print(sprite.hp, 1, 1)
		end
		for k, entity in ipairs(self.entity) do
			--love.graphics.print(entity.velX, entity.drawX, entity.drawY - 15)
			entity:draw()
		end
		self.tmap:draw(2)
		self.tmap:draw(3)
		
		love.graphics.pop()
		
		if self.sprite.samus.hitID then
			love.graphics.print(self.sprite.samus.hitID, 290, 230)
		end
		
		if debugMode then
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.print("X-"..self.sprite.samus.drawX.." Y-"..self.sprite.samus.drawY, 215, 2)
			love.graphics.print(love.timer.getFPS() .. "fps at " .. self.tmap.name, 2, 2)
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.print("X-"..self.sprite.samus.drawX.." Y-"..self.sprite.samus.drawY, 215, 1)
			love.graphics.print(love.timer.getFPS() .. "fps at " .. self.tmap.name, 1, 1)
			if self.sprite.samus.air then
				love.graphics.print("AIR", 150, 1)
				
			end
			if self.sprite.samus.jumpStop then love.graphics.print("STOP", 175, 1) end
			local x, y = self.sprite.samus:getWorld(1, 15, self.tmap.env.tileSize, self.tmap)
			love.graphics.print(x .. " " .. y, 175, 1)
			love.graphics.print("X-" .. self.sprite.samus.posX .. " Y-" .. self.sprite.samus.posY, 1, 17)
			love.graphics.print("hmA-" .. tostring(self.sprite.samus.hmA) .. " hmB-" .. tostring(self.sprite.samus.hmB), 215, 17)
		end	
	end,
	
	spawnSAX = function(self)
		table.insert(self.entity, sprite("spr/samus.png"), 25, 32)
	end
}
