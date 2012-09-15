--[[
	INIT
	A state used to initialise Platformy. This file is mandatory and should be used to set up your game object. A configurable init state is provided by default.
]]

return {
	update = function(self, dt, t, game)
		--initialise Platformy here
		platformy.scale = 2 --this is the default scale of the window
		love.graphics.setDefaultImageFilter("nearest", "nearest") --for that pixel style
		platformy:changeState("world") --to switch state we explicitly call platformy:changeState() We need to do this here to end the init state.
	end,
	
	keyreleased = function(self, key) 
		if key == "escape" then love.event.push("quit") end
	end
}