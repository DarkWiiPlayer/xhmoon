xhmoon = require 'xhmoon'

describe 'xhmoon', ->
	describe 'templates', ->
		setup ->
			export node_handler = (env, tagname, arguments, handle_content) ->
				env.print("<#{tagname}>")
				for key, value in pairs(arguments)
					env.print(key, value)
				handle_content! if handle_content
				env.print("</#{tagname}>")
			export language = xhmoon(node_handler)
		
		it 'should be functions', ->
			assert.is.function language\loadlua [[element()]]
		
		it 'should call print', ->
			template = language\loadlua [[element()]]
			language.environment.print = stub.new()
			template!
			with assert.stub(language.environment.print)
				.was_called(2)
				.was_called_with('<element>')
				.was_called_with('</element>')

		it 'should handle multiple arguments', ->
			template = language\loadlua [[element{foo='foo', bar='bar'}]]
			language.environment.print = stub.new()
			template!
			with assert.stub(language.environment.print)
				.was_called(4)
				.was_called_with('foo', 'foo')
				.was_called_with('bar', 'bar')

		it 'should handle nested arguments', ->
			template = language\loadlua [[element{{foo='foo'}, {bar='bar'}}]]
			language.environment.print = stub.new()
			template!
			with assert.stub(language.environment.print)
				.was_called(4)
				.was_called_with('foo', 'foo')
				.was_called_with('bar', 'bar')

		it 'should handle non-string attributes', ->
			template = language\loadlua [[element{foo={'foo', 'bar'}}]]
			language.environment.print = stub.new()
			template!
			with assert.stub(language.environment.print)
				.was_called(3)
				.was_called_with('foo', 'foo bar')
