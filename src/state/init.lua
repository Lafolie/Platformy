--[[
	INIT
	A state used to initialise Platformy. This file is mandatory and should be used to set up your game object. A configurable init state is provided by default.
]]

return {
	update = function(self, dt, t, game)
		--initialise Platformy here
		local map = {width = 20, height = 15}
		local tileSize = 16
		platformy._res = {width = map.width * tileSize, height = map.height * tileSize} --determine window resolution
		platformy._native = {width = love.graphics.getWidth(), height = love.graphics.getHeight()} --store native resolution
		platformy:setMode() --setup window
		platformy:changeState("world") --to switch state we explicitly call platformy:changeState() We need to do this here to end the init state.
	end,
	
	keyreleased = function(self, key) 
		if key == "escape" then love.event.push("quit") end
	end
}