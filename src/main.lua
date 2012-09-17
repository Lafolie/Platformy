require("req")

love.load = function()
	--everything will be stored here
	cache = require("lib.cache")
	platformy = game()
end

love.update = function(dt)
	platformy:update(dt)
end

love.draw = function()
	platformy:draw()
end

love.focus = function(f)
	platformy:focus(f)
end

love.quit = function()
	platformy:quit()
end

love.keypressed = function(key, unicode)
	platformy:keypressed(key, unicode)
end

love.keyreleased = function(key)
	platformy:keyreleased(key)
end

love.joystickpressed = function(joystick, button)
	platformy:joystickpressed(joystick, button)
end

love.joystickreleased = function(joystick, button)
	platformy:joystickreleased(joystick, button)
end

love.mousepressed = function(x, y, button)
	platformy:mousepressed(x, y, button)
end

love.mousereleased = function(x, y, button)
	platformy:mousereleased(x, y, button)
end