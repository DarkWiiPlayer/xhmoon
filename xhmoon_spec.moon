package.path = './?.lua;'..package.path
xhmoon = require 'xhmoon'

describe 'xhmoon', ->
	setup ->
		export node_handler = (print, tagname, arguments, handle_content) ->
			print("<#{tagname}>")
			handle_content!
			print("</#{tagname}>")

	it 'should return a function', ->
		assert.is.function xhmoon

	describe 'language generator', ->
		it 'should return a language', ->
			lang = xhmoon(node_handler)
			assert.is.table lang

	describe 'languages', ->
		it 'should have a loadlua function', ->
			assert.is.function lang.loadlua

		it 'should have a loadluafile function', ->
			assert.is.function lang.loadluafile

		setup -> export lang = xhmoon(node_handler)

		it 'should generate templates from strings', ->
			assert.is.nil lang\loadlua!
			assert.is.string select 2, lang\loadlua!
			assert.is.function lang\loadlua[[print 'test']]
	
	describe 'templates', ->
		setup -> export lang = xhmoon(node_handler)

		it 'should call print', ->
			printer = spy.new ->
			lang.environment.print = printer
			template = lang\loadlua[[h1 'test']]
			template()
			assert.spy(printer).was_called_with '<h1>'
			assert.spy(printer).was_called_with 'test'
			assert.spy(printer).was_called_with '</h1>'
