-- caverealms v.0.8 by HeroOfTheWinds
-- original cave code modified from paramat's subterrain
-- For Minetest 0.4.8 stable
-- Depends default
-- License: code WTFPL

--grab a shorthand for the filepath of the mod
local modpath = minetest.get_modpath(minetest.get_current_modname())

caverealms = {}

--load companion lua files
dofile(modpath.."/config.lua") --configuration file; holds various constants
dofile(modpath.."/crafting.lua")
dofile(modpath.."/falling_ice.lua")
dofile(modpath.."/nodes.lua")
dofile(modpath.."/caverealms_biomes.lua")
