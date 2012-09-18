--[[
	WORLD
	Core Platformy state. Compiles other modules into a playable game.
]]

return {
	reset = function(self) --called once at load
		--core variables
		self.smoothIndex = 1
		self.smoothFactor = platformy.pref.smoothFactor or 4
		self.smooth = {}
		self.offsetX = 320 / 2
		self.offsetY = 240 / 2
		
		--management tables
		self.map = {}
		self.player = {}
		self.entity = {}
		self.map = map(love.filesystem.load("map/test2.map")())
		self.player = self.map:getEnts()
		
	end,
	
	--[[
		Update order:
			
			Get input,
			Map,
			Player,
			Camera,
			Player (0dt),
			Entity,
			Map drawing
	]]
	
	update = function(self, dt, t)
		--collect input
		if love.keyboard.isDown(platformy.pref.key.left) then self.player[1].control.left = true else self.player[1].control.left = nil end
		if love.keyboard.isDown(platformy.pref.key.right) then self.player[1].control.right = true else self.player[1].control.right = nil end
		if love.keyboard.isDown(platformy.pref.key.jump) then self.player[1].control.jumpPress = true else self.player[1].control.jumpPress = nil end
		
		--update the map(?)
		self.map:update(dt, t)
		
		--update player(s)
		self.player[1]:update(dt, t, self.map, -self.player[1].posX + self.offsetX, -self.player[1].posY + self.offsetY, self.entity)
		
		--determine camera smoothing factor
		local camOffsetX = (self.player[1].posX < self.offsetX or self.player[1].posX > self.map.width * self.map.env.tileSize - self.offsetX) and self.player[1].posX or self.offsetX
		local camOffsetY = (self.player[1].posY < self.offsetY or self.player[1].posY >= self.map.height * self.map.env.tileSize - self.offsetY) and self.player[1].posY or self.offsetY
		--smoothing factor. Used to smooth out the scrolling effect
		local camX = -self.player[1].posX
		local camY = -self.player[1].posY
		self.smooth[self.smoothIndex] = {}
		self.smooth[self.smoothIndex].x = camX
		self.smooth[self.smoothIndex].y = camY
		
		local smoothOffset = {x = 0, y = 0}
		for k, pos in ipairs(self.smooth) do --use the last few frames to determine smoothing
			smoothOffset.x = smoothOffset.x + pos.x
			smoothOffset.y = smoothOffset.y + pos.y
		end
		
		--bound camera to map area
		if camOffsetX < self.offsetX then
			smoothOffset.x = 0
		elseif camOffsetX > self.map.width * self.map.env.tileSize - self.offsetX then
			smoothOffset.x  = -(self.map.width * self.map.env.tileSize) + self.offsetX * 2
			camOffsetX = camOffsetX - (self.map.width - 20) * self.map.env.tileSize
		else
			local max = -(self.map.width * self.map.env.tileSize) + self.offsetX * 2
			smoothOffset.x = math.min(math.max((smoothOffset.x / # self.smooth) + camOffsetX, max), 0)
		end
		
		if camOffsetY < self.offsetY then
			smoothOffset.y = 0
		elseif camOffsetY >= self.map.height * self.map.env.tileSize - self.offsetY then
			smoothOffset.y = -(self.map.height * self.map.env.tileSize) + self.offsetY * 2
			camOffsetY = camOffsetY - (self.map.height - 15) * self.map.env.tileSize
		else
			local max = -(self.map.height * self.map.env.tileSize) + self.offsetY * 2
			smoothOffset.y = math.min(math.max((smoothOffset.y / # self.smooth) + camOffsetY, max), 0)
		end
		
		self.smoothIndex = self.smoothIndex + 1 <= self.smoothFactor and self.smoothIndex + 1 or 1
		
		--update player draw position
		self.player[1]:update(0, t, self.map, camX + camOffsetX, camY + camOffsetY, self.entity)
		
		--update entities
		for k, entity in ipairs(self.entity) do
			entity:update(dt, t, self.map, smoothOffset.x, smoothOffset.y, {})
		end

		self.map.offsetX = smoothOffset.x
		self.map.offsetY = smoothOffset.y
	end,
	
	draw = function(self)
		--push and scale
		love.graphics.push()
		love.graphics.scale(platformy.pref.scale)
			--draw background layers
			love.graphics.draw(self.map.env.background, 0, 0)
			for z = 1, self.map.env.oc - 1 do
				self.map:draw(z)
			end
			--draw player and entites
			for k, entity in ipairs(self.entity) do
				entity:draw()
			end
			self.player[1]:draw()
			--draw occupied layer
			self.map:draw(self.map.env.oc)
			--draw overlays
			for z = self.map.env.oc, # self.map.layout do
				self.map:draw(z)
			end
		love.graphics.pop()
		
		--debug stuff
		if debugMode then
			platformy.print(love.timer.getFPS(), 1, 1)
			platformy.print(self.map.offsetX .. " " .. self.map.offsetY, 1, 15)
		end
	end,
	
	focus = function(self, f)
		--we need to focus
	end,
	
	quit = function(self)
		--code
	end,
	
	keypressed = function(self, key, unicode)
		if key == platformy.pref.key.jump and not self.player[1].air and self.player[1].velY >= 0 then
			self.player[1].control.jump = true
		end
		if key == platformy.pref.key.fire then
			self.player[1].control.fire = true
		end	
	end,
	
	keyreleased = function(self, key)
		--function keys
		if key == "escape" then love.event.push("quit") end --quit on esc
		if key == "f1" then debugMode = not(debugMode) end
		if key == "f2" and not platformy.pref.fullscreen then
			platformy.pref.scale = platformy.pref.scale >=  4 and 1 or platformy.pref.scale + 1
			platformy:setMode()
		end
		if key == "f3" then 
			platformy.pref.fullscreen = not platformy.pref.fullscreen
			if not platformy.pref.fullscreen then
				--find the biggest window size the screen can accomodate 
				platformy.pref.scale = math.min(math.floor(platformy._native.width / 320), math.floor((platformy._native.height - 32) / 240)) --take 32 for title bars and such
				print(math.min(math.floor(platformy._native.width / 320), math.floor((platformy._native.height) / 240)))
				
			end
			platformy:setMode()
		end
		--gameplay keys
		if key == platformy.pref.key.jump then self.player[1].control.jumpRelease = true end
	end,
	
	joystickpressed = function(self, joystick, button)
		--code
	end,
	
	joystickreleased = function(self, joystick, button)
		--code
	end,
	
	mousepressed = function(self, x, y, button)
		--code
	end,
	
	mousereleased = function(self, x, y, button)
		--code
	end	
}