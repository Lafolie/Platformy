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