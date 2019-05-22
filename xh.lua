-- vim: set noexpandtab :miv --

local is51 = _VERSION == 'Lua 5.1'
local global = _ENV or _G

local language -- Function to create a new output language

local function make_environment(node_handler)
	local environment do
		environment = setmetatable({}, {
			__index = function(self, key)
				local _exp_0 = key
				if 'escape' == _exp_0 then
					return function(...)
						return ...
					end
				else
					return global[key] or function(...)
						return self.node(key, ...)
					end
				end
			end
		})
	end

	if is51 then
		setfenv(1, environment)
	end
	local _ENV = _ENV and environment

	local function flatten(tab, flat)
		if flat == nil then
			flat = { }
		end
		for key, value in pairs(tab) do
			if type(key) == "number" then
				if type(value) == "table" then
					flatten(value, flat)
				else
					flat[#flat + 1] = value
				end
			else
				if type(value) == "table" then
					flat[key] = table.concat(value(' '))
				else
					flat[key] = value
				end
			end
		end
		return flat
	end
	local function inner(content)
		for _index_0 = 1, #content do
			local entry = content[_index_0]
			local _exp_0 = type(entry)
			if 'string' == _exp_0 then
				print(escape(entry))
			elseif 'function' == _exp_0 then
				entry()
			else
				print(escape(tostring(entry)))
			end
		end
	end
	node = function(tagname, ...)
		local arguments = flatten({
			...
		})
		local content = { }
		for k, v in ipairs(arguments) do
			content[k] = v
			arguments[k] = nil
		end
		local handle_content
		if #content > 0 then
			handle_content = function()
				return inner(content)
			end
		else
			handle_content = nil
		end
		return node_handler(print, tagname, arguments, handle_content)
	end
	return environment
end

local function derive(self)
	local derivate = language(self.node_handler)

	-- Attempt to copy mactos from old environment
	-- FIXME: the macros keep their own environment, so
	-- 1. they don't make use of new macros and
	-- 2. they use the parents print function
	-- Possible fix: add an init_macros function chain
	local meta = getmetatable(derivate.environment)
	local parent = self.environment
	local __index = meta.__index
	meta.__index = function(self, key)
		return rawget(self, key) or rawget(parent, key) or __index(self, key)
	end

	return derivate
end

local function readfile(file)
	file = assert(io.open(file))
	local content = file:read("*a")
	file:close()
	return content
end

local loadlua if is51 then
	loadlua = function(self, code, name, filter)
		if type(code)~='string' then
			local name = debug.getinfo(1, 'n').name or 'loadlua'
			return nil, 'bad argument #1 to '..name..' (got '..type(code)..', expected string)'
		end
		if name == nil then
			name = "xhmoon"
		end
		if filter then
			local err
			code, err = filter(code)
			if type(code)~='string' then
				local name = debug.getinfo(1, 'n').name or 'loadlua'
				return nil, err, 'bad argument #2 to '..name..' (returned '..type(code)..' instead of string)'
			end
		end
		return setfenv(loadstring(code, name), self.environment)
	end
else
	loadlua = function(self, code, name, filter)
		if type(code)~='string' then
			local name = debug.getinfo(1, 'n').name or 'loadlua'
			return nil, 'bad argument #1 to '..name..' (got '..type(code)..', expected string)'
		end
		if name == nil then
			name = "xhmoon"
		end
		if filter then
			local err
			code, err = filter(code) or code
			if type(code)~='string' then
				local name = debug.getinfo(1, 'n').name or 'loadlua'
				return nil, err or 'bad argument #2 to '..name..' (returned '..type(code)..' instead of string)'
			end
		end
		return load(code, name, "bt", self.environment)
	end
end

local loadluafile = function(self, file, filter)
	return self:loadlua(readfile(file), file, filter)
end

function language(node_handler)
	return {
		node_handler = node_handler,
		derive = derive,
		loadlua = loadlua,
		loadluafile = loadluafile,
		environment = make_environment(node_handler)
	}
end

return language
