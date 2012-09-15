--[[
	CACHE
	A small library that uses weak table values for the caching of assets. Based on a (very) similar script by Bart van Strien.
]]

local cache = {}
local loadItem

--items in the cache use weak table references so that we don't have to manage them ourselves
cache.item = setmetatable({}, {__mode = "v"})

--cache metatable
cache = setmetatable(cache, {
	__index = function(self, type)
		self[type] = function(name)
			return loadItem(type, name)
		end
		return self[type]
	end
})

--cache the files
local loadItem = function(type, name)
	--generate a unique identifier
	local uid = ("%s:%s"):format(type, name)
	
	--return cached item if it already exists
	if cache.item[uid] then return cache.item[uid] end
	
	--check for format handler
	if not cache._load[type] then return error(("Unknown resource type: %s"):format(type)) end
	
	--load the item
	local item, store = cache._load[type](name)
	--cache the item if appropriate
	if item and store then cache.item[uid] = item end
	
	return item
end

--format handlers
cache._load = {
	image = function(name) 
		return love.graphics.newImage(name), true 
	end,
	
	imageData = function(name)
		return love.graphics.newImageData(name), true
	end,
	
	music = function(name)
		return love.audio.newSource(name), nil
	end,
	
	soundData = function(name)
		return love.sound.newSoundData(name), true
	end,
	
	font = function(name)
		local name, size = name:match("^(.-):($d-)$")
		if not name or not size then return nil, false end
		if name == "" then
			return love.graphics.newFont(tonumber(size)), true
		else
			return love.graphics.newFont(name, tonumber(size)), true
		end
	end
}

return cache