xhmoon = require 'xhmoon'

describe 'xhmoon', ->
	setup ->
		export node_handler = (print, tagname, arguments, handle_content) ->
			print("<#{tagname}>")
			handle_content!
			print("</#{tagname}>")
	
	describe 'initializers', ->
		setup -> export language = xhmoon(node_handler)

		it 'should be called on new languages', ->
			initializer = stub.new!
			----------------------------------------
			lang = xhmoon(node_handler, => initializer @)
			----------------------------------------
			assert.stub(initializer).was_called_with(lang.environment)

		it 'should be called on derived languages', ->
			initializer = stub.new!
			parent_init = stub.new!
			----------------------------------------
			parent = xhmoon node_handler, => parent_init @
			child = parent\derive => initializer @
			----------------------------------------
			assert.stub(initializer).was_called_with child.environment
			assert.stub(parent_init).was_called!

		it 'should set values on new languages', ->
			lang = xhmoon node_handler, (_ENV) -> export foo = 'bar'
			----------------------------------------
			assert.is.equal 'bar', lang.environment.foo

		it 'should set values on derived languages', ->
			lang = language\derive (_ENV) -> export foo = 'bar'
			----------------------------------------
			assert.is.equal 'bar', lang.environment.foo
