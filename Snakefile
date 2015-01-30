# dmc-e4x

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "dmc-e4x"
	include: "../DMC-Corona-Library/snakemake/Snakefile"

module_config = {
	"name": "dmc-e4x",
	"module": {
		"dir": "dmc_corona",
		"files": [
			"dmc_e4x.lua"
		],
		"requires": [
			"dmc-corona-boot",
			"DMC-Lua-Library"
		]
	},
	"tests": {
		"files": [],
		"requires": []
	}
}

register( "dmc-e4x", module_config )

