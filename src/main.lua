require("req")

love.load = function()
	met = game()
end

love.update = function(dt)
	met:update(dt)
end

love.draw = function()
	met:draw()
end

love.keypressed = function(key)
	if key == met.key.jump and not met.sprite.samus.air and met.sprite.samus.velY >= 0 then
		met.sprite.samus.control.jump = true
	end
	if key == met.key.fire then
		met.sprite.samus.control.fire = true
	end
end

love.keyreleased = function(key)
	if key == "escape" then love.event.push("quit") end
	if key == "f1" then debugMode = not(debugMode)  end
	if key == "f2" then
		met.scale = met.scale >=  4 and 1 or met.scale + 1
		love.graphics.setMode(met.scale * 320, met.scale * 240, nil, true, 0)
	end
	if key == "f3" then love.graphics.toggleFullscreen() end
	if key == "f4" then 
		met.key.up = met.key.up == "up" and "w" or "up"
		met.key.down = met.key.down == "down" and "s" or "down"
		met.key.left = met.key.left == "left" and "a" or "left"
		met.key.right = met.key.right == "right" and "d" or "right"
		met.key.jump = met.key.jump == "x" and "/" or "x"
		met.key.fire = met.key.fire == "z" and "." or "z"
	end
	if key == met.key.jump then met.sprite.samus.control.jumpRelease = true end
	if key == met.key.fire then met.sprite.samus.control.fire = nil end
end