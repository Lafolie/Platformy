--[[
	GAME
	Game class. Handles states, manages assets such as sounds and images and is the entry point for content.
]]
local state = {}

class "game" {
	__init__ = function(self)
		--set prefrences
		self.pref = self:loadFile("preferences.txt") or {
			_fileName = "preferences.txt",
			scale = 2,
			vsync = true,
			key = {
				up = "w",
				down = "s",
				left = "a",
				right = "d",
				jump = ".",
				fire = "/"
			},
			pad = {}
		}
			
		--load save
		self.save = self:loadFile()
		--create gamestates
		assert(love.filesystem.isDirectory("state"), "No states could be found!")
		local stateFiles = love.filesystem.enumerate("state")
		for k, file in ipairs(stateFiles) do
			local name = file:match("^(.+)%.lua$")
			state[name] = gamestate(name, file)
		end
		assert(state.init, "Could not find mandatory file \"state/init.state\"!")
		self:changeState("init")
	end,
	
	update = function(self, dt)
		--core thingies
		local t = love.timer.getTime()
		
		--update current state
		self.state:update(dt, t)
	end,
	
	draw = function(self)
		self.state:draw()
	end,
	
	focus = function(self, f)
		self.state:focus(f)
	end,
	
	quit = function(self)
		self:saveFile(self.pref)
		self.state:quit()
	end,
	
	keypressed = function(self, key, unicode)
		self.state:keypressed(key, unicode)
	end,
	
	keyreleased = function(self, key)
		self.state:keyreleased(key)
	end,
	
	joystickpressed = function(self, joystick, button)
		self.state:joystickpressed(joystick, button)
	end,
	
	joystickreleased = function(self, joystick, button)
		self.state:joystickreleased(joystick, button)
	end,
	
	mousepressed = function(self, x, y, button)
		self.state:mousepressed(x, y, button)
	end,
	
	mousereleased = function(self, x, y, button)
		self.state:mousereleased(x, y, button)
	end,
	
	changeState = function(self, name)
		assert(name, "changeState issues with invalid state name!")
		assert(state[name], "Unknown gamestate " .. name .. "!")
		self.state = state[name]
		self.state:reset()
	end,
	
	--write a (non-serial) table to a file. The filename should be a property of "data": data._fileName = "*.extn"
	saveFile = function(self, data)
		assert(type(data) == "table", "Tables must be provided to saveFile!")
		if not love.filesystem.isDirectory("save") then asser(love.filesystem.mkdir("save"), "Unable to create save directory in " .. love.filesystem.getSaveDirectory() .. "!") end --make the save folder if required
		file = love.filesystem.newFile(data._fileName)
		file:open("w")
		
		local function serial(table, scope)
			scope = scope or ""
			for k, v in pairs(table) do
				if k ~= "_fileName" then 
					if type(v) == "table" then
						serial(v, scope .. tostring(k) .. ".")
					else
						x = file:write(scope .. k .. "=" .. tostring(v) .. "\n") --write value
						if not x then return nil end
					end
				end
			end
		end

		serial(data)
		
		return true
	end,
	
	--load a file. If no specific file is given it returns the latest save file
	loadFile = function(self, name)
		if not love.filesystem.isDirectory("save") then assert(love.filesystem.mkdir("save"), "Unable to create save directory in " .. love.filesystem.getSaveDirectory() .. "!") end
		--load the latest save file if no file is given (useful for 'continue' option)
		if not name then
			local saveFiles = love.filesystem.enumerate("save")
			local orderedFiles = {}
			for k, file in ipairs(saveFiles) do
				--ignore files such as .DS_Store
				if not (file:sub(1, 1) == ".") and file:match("%.save$") then
					table.insert(orderedFiles, {f = file, t = love.filesystem.getLastModified("save/" .. file) or 0})
				end
			end
			if # orderedFiles ~= 0 then
				--sort the files in modified order
				table.sort(orderedFiles, function(a, b) return a.t > b.t end)
				name = orderedFiles[1]
			end
		end
		--don't do anything if there are no saves
		if name then
			if love.filesystem.isFile(name) then
				
				local saveFile = {} --data from the file
				local pointer
				--find tables
				--ASSUME: key.up
				local function deserial(value)
					pointer = saveFile
					local scope, dotCount = value:gsub("%.", "%1")
					for x = 1, dotCount do
						local element = scope:match("^(..-)%.") --get the leftmost index
						scope = scope:match("^" .. element .. "%.(.+)") --trim the current index for the next iteration
						if not pointer[element] then pointer[element] = {} end --create the table if needed
						pointer = pointer[element] --set the pointer to the current level
					end
					return scope
				end
				
				--load the data
				for l in love.filesystem.lines(name) do
					local k, v = l:match("^(..-)=(.+)$")
					if k and v then
						local index = deserial(k)
						if v ~= "nil" and v ~= "false" then --ignore nil values that may have been set by the player
							pointer[index] = tonumber(v) and tonumber(v) or v
						end
					end
				end
				saveFile._fileName = name
				return saveFile
			end
		end
	end
}

class "gamestate" {
	__init__ = function(self, name, file)
		assert(name, "State declared with no name!")
		assert(not state[name], "State declared with ambiguous name!")
		local newstate = love.filesystem.load("state/" .. file)()
		for k, v in pairs(newstate) do
			self[k] = v --assimilate!!
		end
		
		local callbacks = {"reset", "update", "draw", "focus", "quit", "keypressed", "keyreleased", "joystickpressed", "joystickreleased", "mousepressed", "mousereleased"}
		for k, call in ipairs(callbacks) do
			self[call] = self[call] or function() end
		end	
	end
}