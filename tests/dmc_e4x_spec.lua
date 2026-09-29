--====================================================================--
-- tests/dmc_e4x_spec.lua
--
-- Unit tests for dmc-e4x, using Luna Test.
-- Run with tests/run_unit.sh
--
-- lua-e4x has the full specs; these check the wrapper, and that
-- lua-e4x's fixes come through it
--====================================================================--


module(..., package.seeall)



--====================================================================--
--== Setup


local E4X, LuaE4X

local BOOKS = [[
<order>
	<book ISBN="0942407296" publisher="Prentice Hall">
		<title>Baking Extravagant Pastries with Kumquats</title>
		<author><lastName>Contino</lastName><firstName>Chuck</firstName></author>
	</book>
	<book ISBN="0865436401" publisher="Prentice Hall">
		<title>Emu Care and Breeding</title>
		<editor><lastName>Case</lastName><firstName>Justin</firstName></editor>
	</book>
</order>
]]

function suite_setup()
	E4X = require 'dmc_corona.dmc_e4x'
	LuaE4X = require 'lib.dmc_lua.lua_e4x'
end



--====================================================================--
--== Tests


function test_module()
	assert_equal( 'table', type( E4X ) )
	assert_equal( 'string', type( E4X.VERSION ) )
	assert_equal( 'function', type( E4X.parse ) )
	assert_equal( '0.2.0', E4X.__version )
end

function test_shared_module_untouched()
	assert_not_equal( LuaE4X, E4X )
	assert_nil( LuaE4X.VERSION )
end

function test_no_global_extend()
	assert_nil( rawget( _G, '_extend' ) )
end

function test_quick_start()
	local xml = E4X.parse( BOOKS )
	assert_equal( 'order', xml:name() )
	assert_equal( 2, xml.book:length() )
	assert_equal( 'Case', xml.book.editor.lastName:toString() )
	assert_equal( 'Emu Care and Breeding', xml.book[2].title:toString() )
	assert_equal( '0942407296', xml.book[1]['@ISBN']:toString() )
end

-- fixed in lua-e4x 0.2.0; dmc-e4x's README named these as bugs

function test_underscore_and_dot_names()
	local xml = E4X.parse( '<a><first_name>Chuck</first_name><x.y>1</x.y></a>' )
	assert_equal( 'Chuck', xml.first_name:toString() )
	assert_equal( '1', xml['x.y']:toString() )
end

function test_cdata()
	local xml = E4X.parse( '<a><b><![CDATA[1 < 2 & 3]]></b></a>' )
	assert_equal( '1 < 2 & 3', xml.b:toString() )
end

function test_text_next_to_children()
	local xml = E4X.parse( '<a>text<b>1</b></a>' )
	assert_equal( '1', xml.b:toString() )
end

function test_comment_not_text()
	local xml = E4X.parse( '<a><!-- note --><b>1</b></a>' )
	assert_equal( '1', xml.b:toString() )
	assert_equal( 1, xml:children():length() )
end
