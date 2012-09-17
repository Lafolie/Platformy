--[[
	WORLD
	Core Platformy state. Compiles other modules into a playable game.
]]

return {
	reset = function(self) --called once at load
		self.map = {}
		self.player = {}
		self.entity = {}
		self.map = map(love.filesystem.load("map/test.map")())
		self.entity = self.map:getEnts()
		
	end,
	
	update = function(self, dt, t)
		--collect input
		if love.keyboard.isDown("a") then self.entity[1].control.left = true else self.entity[1].control.left = nil end
		if love.keyboard.isDown("d") then self.entity[1].control.right = true else self.entity[1].control.right = nil end
		if love.keyboard.isDown(".") then self.entity[1].control.jumpPress = true else self.entity[1].control.jumpPress = nil end
		
		--update the map(?)
		self.map:update(dt, t)
		
		--update entities
		for k, entity in ipairs(self.entity) do
			entity:update(dt, t, self.map, 0, 0, {})
		end
		
		self.map.offsetX = 0
		self.map.offsetY = 0
	end,
	
	draw = function(self)
		--push and scale
		love.graphics.push()
		love.graphics.scale(platformy.scale)
		--draw background layers
		for z = 1, self.map.env.oc - 1 do
			self.map:draw(z)
		end
		--draw player and entites
		for k, entity in ipairs(self.entity) do
			entity:draw()
		end
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
		if key == "." and not self.entity[1].air and self.entity[1].velY >= 0 then
			self.entity[1].control.jump = true
		end
		if key == "/" then
			self.entity[1].control.fire = true
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
		if key == "." then self.entity[1].control.jumpRelease = true end
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