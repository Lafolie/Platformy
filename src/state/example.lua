--[[
	EXAMPLE
	An example state that may even be used as a template. Don't forget that functions to be used as 'state:method()' need the leading 'self' property in their method declaration parameters.
]]

--game content is 'parsed' using love.filesystem.load()() so it is proper for content to return a table that contains properties.
return {
	--declare variables and such here (don't forget the commas!)
	reset = function(self) --called once at load
		self.disp = 0
	end,
	
	update = function(self, dt, t)
		self.disp = self.disp + dt
	end,
	
	draw = function(self)
		love.graphics.print(self.disp, 1, 1)
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