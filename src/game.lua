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
		self.saveGame = {["progress"] = {}, ["items"] = {}, ["energy"] = 99, ["missile"] = 0, ["location"] = {0, 0}}
		self.mode = "map"
		self.key = {["up"] = "w", ["down"] = "s", ["left"] = "a", ["right"] = "d", ["jump"] = " ", ["fire"] = "<"}
		self.offsetX = love.graphics.getWidth() / 2
		self.offsetY = love.graphics.getHeight() / 2
		love.graphics.setIcon(love.graphics.newImage("spr/platformy.png"))

		--Graphic content
		self.library = {}
		self.sprite = {}
		--local layout = {{6, 0, 18, 32}, {29, 1, 20, 31}, {52, 1, 22, 31}, {75, 1, 24, 31}}
		self.sprite.samus = entity(spriteset("spr/samus.png", 25, 32))
		self.sprite.samus.posX = 112
		self.sprite.samus.posY = 32
		
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
		local properties = {noclip, clip, ramp, ramp2, noclip} --load tileset passabilty data
		local tempmap = {
							{2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
							{2, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
							{2, 2, 1, 1, 1, 5, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
							{2, 2, 1, 1, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
							{2, 2, 1, 1, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
							{2, 2, 1, 1, 2, 2, 2, 1, 1, 2, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2},
							{2, 1, 1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2},
							{2, 1, 1, 1, 2, 2, 1, 1, 2, 2, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2},
							{2, 1, 1, 1, 2, 2, 1, 1, 2, 2, 1, 3, 5, 1, 1, 1, 2, 2, 2, 2},
							{2, 1, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 2, 2, 1, 1, 1, 2, 2, 2},
							{2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 2},
							{2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2},
							{2, 1, 2, 1, 2, 1, 2, 4, 1, 1, 3, 4, 1, 3, 2, 4, 1, 2, 2, 2},
							{2, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 2},
							{2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2}
						}
		self.tmap = map(tempmap, tileset("spr/tiles.png", properties, self.environment.tileSize))
		
		--Game content
		self.overworld = {}
		
	end,
	
	update = function(self, dt)
		--Core variables and surch
		local t = love.timer.getTime()
		love.keypressed = function(key)
			if key == self.key.jump then
				self.sprite.samus.control.jump = true
			end
		end
		
		love.keyreleased = function(key)
			if key == "escape" then love.event.push("quit") end
			if key == "f1" then debugMode = not(debugMode)  end
			if key == "f2" then
				self.scale = self.scale >=  4 and 1 or self.scale + 1
				love.graphics.setMode(self.scale * 320, self.scale * 240, nil, true, 0)
			end
			if key == "f3" then love.graphics.toggleFullscreen() end
			if key == "f4" then 
				self.key.up = self.key.up == "up" and "w" or "up"
				self.key.down = self.key.down == "down" and "s" or "down"
				self.key.left = self.key.left == "left" and "a" or "left"
				self.key.right = self.key.right == "right" and "d" or "right"
			end
			if key == self.key.jump then self.sprite.samus.control.jumpRelease = true end
		end
		
		if self.mode == "map" then
			--Temp stuff
			if love.keyboard.isDown(self.key.left) then self.sprite.samus.control.left = true else self.sprite.samus.control.left = nil end
			if love.keyboard.isDown(self.key.right) then self.sprite.samus.control.right = true else self.sprite.samus.control.right = nil end
			self.tmap:update(dt, t)

			for k, sprite in pairs(self.sprite) do
				sprite:update(dt, t, self.tmap)
			end
			
		end
	end,
	
	draw = function(self)
		love.graphics.push()
		love.graphics.scale(self.scale)
		self.tmap:draw()
		for k, sprite in pairs(self.sprite) do
			sprite:draw(self.offsetX, self.offsetY)
		end
		love.graphics.pop()
		if debugMode then
			love.graphics.setColor(0, 0, 0, 255)
			love.graphics.print(self.sprite.samus.velY or nil, 215, 2)
			love.graphics.print(love.timer.getFPS() .. "fps at " .. self.tmap.name, 2, 2)
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.print(self.sprite.samus.velY or nil, 215, 1)
			love.graphics.print(love.timer.getFPS() .. "fps at " .. self.tmap.name, 1, 1)
			if self.sprite.samus.air then
				love.graphics.print("AIR", 150, 1)
				
			end
			if self.sprite.samus.jumpStop then love.graphics.print("STOP", 175, 1) end
			local x, y = self.sprite.samus:getWorld(1, 15, self.tmap.env.tileSize, self.tmap)
			love.graphics.print(x .. " " .. y, 175, 1)
			love.graphics.print("X-" .. self.sprite.samus.posX .. " Y-" .. self.sprite.samus.posY, 1, 17)
		end	
	end
}
					