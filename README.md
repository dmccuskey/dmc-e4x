# dmc-e4x

Read XML in a Solar2D (formerly Corona SDK) app with dot syntax: `xml.book.title` finds every `title` in every `book`.

dmc-e4x is [lua-e4x](https://github.com/dmccuskey/lua-e4x) packaged like the other DMC Solar2D libraries. It parses an XML string into a tree you search the way [E4X](https://en.wikipedia.org/wiki/ECMAScript_for_XML) (ECMAScript for XML, as in ActionScript 3) does:

```lua
local E4X = require 'dmc_corona.dmc_e4x'

local xml = E4X.parse( [[
<order>
	<book ISBN="0942407296"><title>Baking Extravagant Pastries with Kumquats</title></book>
	<book ISBN="0865436401"><title>Emu Care and Breeding</title></book>
</order>
]] )

print( xml.book:length() )                  --> 2
print( xml.book[2].title:toString() )       --> Emu Care and Breeding
print( xml.book[1]['@ISBN']:toString() )    --> 0942407296
```

## Features

- `E4X.parse()` turns an XML string into a tree of nodes
- Dot traversal: `xml.book.author.lastName` searches children, then their children, and so on
- Attributes with `'@name'`: `xml.book['@ISBN']`
- `toXmlString()` writes a node back out as XML
- Pure Lua, no plugins needed; MIT licensed

It reads well-formed, simple XML: elements, attributes, text. It doesn't understand CDATA, comments or DTDs, and element names with `_` or `.` are read wrong; see [Known Issues](#known-issues) before using it on XML you don't control.

## Quick Start

The following code will get you up and running in about 10 minutes in the Solar2D Simulator on macOS or Windows. It reads an XML file from your project and shows the books in it on screen.

Prerequisites: the [Solar2D](https://solar2d.com/) Simulator and a copy of this repository (`git clone https://github.com/dmccuskey/dmc-e4x.git`, or download the ZIP from GitHub).

### 1. Copy the Library into Your Project

Copy these from this repository into the root of your project folder:

```text
dmc_corona_boot.lua     loader for the DMC libraries
dmc_corona.cfg          configuration
dmc_corona/             dmc-e4x and the modules it needs
```

**Going further:** keep the libraries in a subfolder, or combine several DMC libraries ([dmc-corona-boot Configuration](https://github.com/dmccuskey/dmc-corona-boot/blob/master/docs/configuration.md)).

### 2. Parse Some XML

Create `books.xml` in the project folder:

```xml
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
```

Create `main.lua` next to it:

```lua
local E4X = require 'dmc_corona.dmc_e4x'

local path = system.pathForFile( 'books.xml', system.ResourceDirectory )
local file = io.open( path, 'r' )
local xml = E4X.parse( file:read( '*a' ) )
file:close()

print( xml:name() )
print( xml.book:length() )
print( xml.book.editor.lastName:toString() )
```

Open the project in the Simulator. The screen stays black; the console shows:

```text
order
2
Case
```

If the console shows `module 'dmc_corona.dmc_e4x' not found` instead, `dmc_corona/` is missing from the root of the project folder.

`xml` is the root element, `<order>`. `xml.book` searches its children for `book` elements and returns them as a list; `.editor` then searches every book in that list (only the second has one), and `.lastName` every editor found.

### 3. Show Each Book

Add this to the end of `main.lua`:

```lua
local y = 80
for i, book in xml.book:nodes() do
	local line = i .. ". " .. book.title:toString() .. " (" .. book['@ISBN']:toString() .. ")"
	display.newText{ text=line, x=display.contentCenterX, y=y,
		width=display.contentWidth - 20, fontSize=16 }
	y = y + 60
end

print( xml.book[2]:toXmlString() )
```

The Simulator restarts the app when the file is saved. Each book's title and ISBN is on screen, and the console also shows the second book written back out as XML, on one line.

`nodes()` loops over a list; `[2]` picks one node from it (lists start at 1). `'@ISBN'` reads an attribute. The attributes in `toXmlString()` may come out in another order.

**Going further:** every method on lists and nodes ([lua-e4x API reference](https://github.com/dmccuskey/lua-e4x/blob/master/docs/api.md)).

To update, copy `dmc_corona_boot.lua` and `dmc_corona/` again from the newer version. Keep your own `dmc_corona.cfg` if you have changed it.

## Documentation

`require 'dmc_corona.dmc_e4x'` returns lua-e4x's module, so its documentation applies as written:

- [API reference](https://github.com/dmccuskey/lua-e4x/blob/master/docs/api.md): the module, [Lists and Nodes](https://github.com/dmccuskey/lua-e4x/blob/master/docs/api.md#lists-and-nodes), dot traversal, attributes, every method
- [Known Issues](https://github.com/dmccuskey/lua-e4x/blob/master/docs/api.md#known-issues) of the parser

## Configuration

dmc-e4x has no settings: `dmc_corona.cfg` needs no section for it, only the `[DMC_CORONA]` section that tells the loader where the libraries are. See [dmc-corona-boot Configuration](https://github.com/dmccuskey/dmc-corona-boot/blob/master/docs/configuration.md).

## Known Issues

The bugs of the parser are in lua-e4x's [Known Issues](https://github.com/dmccuskey/lua-e4x/blob/master/docs/api.md#known-issues); the ones most likely to be met: element names with `_` or `.` are cut short (`<first_name>` is read as `first`), CDATA sections raise an error, and searching an element that holds text next to child elements raises `attempt to call method 'name' (a nil value)`. In `dmc_e4x.lua`:

- It sets the global `_extend` (its copy of `Utils.extend()` declares the inner function without `local`).
- Its version (`0.1.0`) isn't available to code.

## Development

Only `dmc_corona/dmc_e4x.lua` is written in this repository. It loads the DMC boot loader and returns lua-e4x's module from `lib.dmc_lua.lua_e4x`. Everything else is a generated copy; fix it in its own repository, then rebuild:

| file | owner |
|---|---|
| every file in `dmc_corona/lib/dmc_lua/` | [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library), which copies them from the `lua-*` repositories ([lua-e4x](https://github.com/dmccuskey/lua-e4x), ...) |
| `dmc_corona_boot.lua` | [dmc-corona-boot](https://github.com/dmccuskey/dmc-corona-boot) |

The copies are made by Snakemake from sibling checkouts of the repositories above (`../DMC-Lua-Library`, `../dmc-corona-boot`, `../DMC-Corona-Library` for the shared rules). From this repository's root folder:

```sh
snakemake --cores 1 build_all
```

dmc-e4x has no tests of its own; lua-e4x's are in its `spec/`. The Quick Start is the check that the package loads in Solar2D.

## License

dmc-e4x is released under the [MIT License](LICENSE).
