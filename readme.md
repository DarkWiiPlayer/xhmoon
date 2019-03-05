XHMoon
================================================================================

A simple helper library to be used in MoonXML to create a generator syntax for
XML and HTML code.

When required, it returns a single function which returns a new language.
This function accepts a node handler function as its argument.
The node handler will be called for each node (XML tag) and output its
corresponding representation in the language.

A node handler should accept four arguments:

- print
	The function it should use to output text
- Tag name
	The name of the tag to be generated
- attributes
	A table of key-value pairs representing attributes of the node
- handle\_content
	A function that should be called where the content of the node should go

An example node handler for XML:

	function(print, tag, args, inner)
		local argstrings = {}
		for key, value in pairs(args) do
			table.insert(argstrings, ('%s="%s"'):format(key, value))
		end
		if inner
			print(([[<%s %s >]]):format(tag, table.concat(argstrings)))
			inner()
			print(([[</%s>]]):format(tag))
		else
			print(([[<%s %s />]]):format(tag, table.concat(argstrings)))
		end
	end

The *language* returned by the function provides an environment in which to run
another function and can be duplicated with the `derive` method.
Derived languages inherit all of its parents properties and can be modified and
extended as needed.

Changelog
--------------------------------------------------------------------------------

### 1.1.1
- Fix severe bugs in loadluafile
- Delete moonscript file and just switch to Lua

### 1.1
- Add loadlua and loadluafile functions
