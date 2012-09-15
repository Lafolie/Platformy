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

--love.keypressed = function(key, unicode)
--	if key == platformy.key.jump and not platformy.sprite.samus.air and platformy.sprite.samus.velY >= 0 then
--		platformy.sprite.samus.control.jump = true
--	end
--	if key == platformy.key.fire then
--		platformy.sprite.samus.control.fire = true
--	end
--end
--
--love.keyreleased = function(key)
--	if key == "escape" then love.event.push("quit") end
--	if key == "f1" then debugMode = not(debugMode)  end
--	if key == "f2" then
--		platformy.scale = platformy.scale >=  4 and 1 or platformy.scale + 1
--		love.graphics.setMode(platformy.scale * 320, platformy.scale * 240, nil, true, 0)
--	end
--	if key == "f3" then love.graphics.toggleFullscreen() end
--	if key == "f4" then 
--		platformy.key.up = platformy.key.up == "up" and "w" or "up"
--		platformy.key.down = platformy.key.down == "down" and "s" or "down"
--		platformy.key.left = platformy.key.left == "left" and "a" or "left"
--		platformy.key.right = platformy.key.right == "right" and "d" or "right"
--		platformy.key.jump = platformy.key.jump == "x" and "/" or "x"
--		platformy.key.fire = platformy.key.fire == "z" and "." or "z"
--	end
--	if key == platformy.key.jump then platformy.sprite.samus.control.jumpRelease = true end
--	if key == platformy.key.fire then platformy.sprite.samus.control.fire = nil end
--end

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