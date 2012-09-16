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
	end,
	
	update = function(self, dt, t)
		self.map:update(dt, t)
		self.map.offsetX = 0
		self.map.offsetY = 0
	end,
	
	draw = function(self)
		love.graphics.push()
		love.graphics.scale(platformy.scale)
		self.map:draw(2)
		love.graphics.print("Hello world", 1, 1)
		love.graphics.pop()
	end,
	
	focus = function(self, f)
		--we need to focus
	end,
	
	quit = function(self)
		--code
	end,
	
	keypressed = function(self, key, unicode)
		--input handling
	end,
	
	keyreleased = function(self, key)
		if key == "escape" then love.event.push("quit") end --quit on esc
		if key == "f1" then debugMode = not(debugMode) end
		if key == "f2" then
		platformy.scale = platformy.scale >=  4 and 1 or platformy.scale + 1
		love.graphics.setMode(platformy.scale * 320, platformy.scale * 240, nil, true, 0)
	end

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