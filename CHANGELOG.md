# Changelog

## 0.2.0 (2026-09-29)

### Changed

- The parser is now lua-e4x 0.2.0's, from DMC-Lua-Library's `lib.dmc_lua.lua_e4x`: `require 'dmc_corona.dmc_e4x'` returns a copy of it, so the shared module is left as it is. From lua-e4x 0.2.0:
  - Element names with `_` or `.` are read whole (`<first_name>` was read as `first`).
  - CDATA sections are read as text instead of raising an error.
  - Searching an element that holds text next to child elements no longer raises `attempt to call method 'name'`.
  - Comments, processing instructions and the DOCTYPE are skipped instead of becoming text.
  - `toXmlString()` writes attributes in the order they're written, and encodes entities again.
  - The rest are in lua-e4x's [Known Issues](https://github.com/dmccuskey/lua-e4x/blob/master/docs/api.md#known-issues).
- Rebuilt with dmc-corona-boot 1.6.0 and the current DMC-Lua-Library.

### Added

- `VERSION` in the table the module returns.
- Unit tests: `tests/run_unit.sh`, plain Lua 5.1.

### Removed

- The copy of `Utils.extend()`, which set the global `_extend`; the module uses DMC-Lua-Library's `lua_utils`.

## 0.1.0

- First release: lua-e4x 0.1.1 packaged for Solar2D.
