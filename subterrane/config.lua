
local CONFIG_FILE_PREFIX = "subterrane_"

subterrane.config = {}

-- This function based on kaeza/minetest-irc/config.lua and used under the
-- terms of BSD 2-clause license.
local function setting(stype, name, default)
	local value
	if stype == "bool" then
		value = minetest.setting_getbool(CONFIG_FILE_PREFIX..name)
	elseif stype == "string" then
		value = minetest.setting_get(CONFIG_FILE_PREFIX..name)
	elseif stype == "number" then
		value = tonumber(minetest.setting_get(CONFIG_FILE_PREFIX..name))
	end
	if value == nil then
		value = default
	end
	subterrane.config[name] = value
end

--generation settings
setting("number", "ymin", -31000) --bottom realm limit
setting("number", "ymax", -700) --top realm limit
setting("number", "tcave", 0.5) --cave threshold

--should player spawn in caves?
setting("bool", "cavespawn", false)
