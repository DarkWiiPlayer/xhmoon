--- These tools facilitate creating DSLs to generate arbitrary documents of XML-like structure.
-- @module xhmoon

is51 = _VERSION == 'Lua 5.1'

global = _ENV or _G
make_environment = (node_handler) ->
	environment = do
		setmetatable {}, {
			__index: (key) =>
				switch key
					when 'escape'
						(...) -> ...
					else
						global[key] or (...) ->
							@.node(key, ...)
		}
	
	if is51
		setfenv(1, environment)
	_ENV = _ENV and environment

	flatten = (tab, flat={}) ->
		for key, value in pairs tab
			if type(key)=="number"
				if type(value)=="table"
					flatten(value, flat)
				else
					flat[#flat+1]=value
			else
				if type(value)=="table"
					flat[key] = table.concat value ' '
				else
					flat[key] = value
		flat
	
	inner = (content) ->
		for entry in *content
			switch type entry
				when 'string' print escape entry
				when 'function' entry!
				else print escape tostring entry

	export node = (tagname, ...) ->
		arguments = flatten{...}
		content = {}
		-- Remove numeric indices into *content*
		for k,v in ipairs arguments do
			content[k]=v
			arguments[k]=nil
		local handle_content
		if #content > 0
			handle_content = -> inner content
		else
			handle_content = nil
		node_handler(print, tagname, arguments, handle_content)
	environment

call = (fnc) =>
	if type(fnc) != 'function'
		error "Argument must be a function!", 3
	error "This land is peaceful, it's inhabitants kind. But thou dost not belong.", 3

local language

---
-- @type language

--- Derives a new language that inherits from the current one.
-- @function derive
derive = =>
	derivate = language(@node_handler)
	meta = getmetatable derivate
	meta.__index = @
	meta = getmetatable derivate.environment -- Pitfall: Can't just set __index as it already exists
	parent = @environment
	__index = meta.__index
	meta.__index = (key) => rawget(@, key) or rawget(parent, key) or __index(@, key)
	return derivate

--- Loads an entire file as a string
readfile = (file) ->
	file = assert io.open(file)
	content = file\read("*a")
	file\close()
	content

--- Loads a string of lua code with a language environment
-- @function load
loadlua = if lua51 then
	(code, name="xhmoon", filter) =>
		if filter then
			setfenv(filter(load(code)), name, @environment)
		else
			setfenv(load(code), name, @environment)
else
	(code, name="xhmoon", filter) =>
		if filter then
			load(filter(code), name, "bt", @environment)
		else
			load(code, name, "bt", @environment)

loadluafile = (file, filter) => @loadlua(readfile(file), file, filter)

---
-- @section language

--- Creates a new language
-- @function language
-- @tparam function node_handler A function that handles a node.
language = (node_handler) ->
	setmetatable {
		:node_handler
		:derive
		:loadlua
		:loadluafile
		environment: make_environment node_handler
		}, {__call: call}

language
