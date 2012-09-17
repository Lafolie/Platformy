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
		self.offsetX = (love.graphics.getWidth() * 0.5) / platformy.pref.scale
		self.offsetY = (love.graphics.getHeight() * 0.5) / platformy.pref.scale
		
		--management tables
		self.map = {}
		self.player = {}
		self.entity = {}
		self.map = map(love.filesystem.load("map/test.map")())
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
		local camOffsetY = (self.player[1].posY < self.offsetY or self.player[1].posY > self.map.height * self.map.env.tileSize - self.offsetY) and self.player[1].posY or self.offsetY
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
		
		smoothOffset.x = camOffsetX ~= self.offsetX and 0 or (smoothOffset.x / # self.smooth) + camOffsetX
		smoothOffset.y = camOffsetY ~= self.offsetY and 0 or (smoothOffset.y / # self.smooth) + self.offsetY
		
		
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
		if key == "f2" then
			platformy.pref.scale = platformy.pref.scale >=  4 and 1 or platformy.pref.scale + 1
			love.graphics.setMode(platformy.pref.scale * 320, platformy.pref.scale * 240, nil, true, 0)
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