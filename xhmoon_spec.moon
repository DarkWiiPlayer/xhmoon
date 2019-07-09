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

		describe 'loadlua', -> pending 'should work', -> nil

		it 'should have a loadluafile function', ->
			assert.is.function lang.loadluafile

		describe 'loadluafile', -> pending 'should work', -> nil

		setup -> export lang = xhmoon(node_handler)

		it 'should generate templates from strings', ->
			assert.is.nil lang\loadlua!
			assert.is.string select 2, lang\loadlua!
			assert.is.function lang\loadlua[[print 'test']]
	
	describe 'derived languages', ->
		setup ->
			lang = xhmoon(node_handler)
			lang.foo = ->
			export derived = lang\derive!

		it 'should have a loadlua function', ->
			assert.is.function derived.loadlua

		it 'should have a loadluafile function', ->
			assert.is.function derived.loadluafile

		it 'should keep their parents methods', ->
			assert.is.function derived.foo
