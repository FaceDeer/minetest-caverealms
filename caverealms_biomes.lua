--grab a shorthand for the filepath of the mod
local modpath = minetest.get_modpath(minetest.get_current_modname())

if caverealms.config.falling_icicles == true then
	dofile(modpath.."/falling_ice.lua") --complicated function for falling icicles
	print("[caverealms] falling icicles enabled.")
end

local FORTRESSES = caverealms.config.fortresses --true | Should fortresses spawn?
local FOUNTAINS = caverealms.config.fountains --true | Should fountains spawn?

-- Parameters

local STAGCHA = caverealms.config.stagcha --0.002 --chance of stalagmites
local STALCHA = caverealms.config.stalcha --0.003 --chance of stalactites
local CRYSTAL = caverealms.config.crystal --0.007 --chance of glow crystal formations
local GEMCHA = caverealms.config.gemcha --0.03 --chance of small glow gems
local MUSHCHA = caverealms.config.mushcha --0.04 --chance of mushrooms
local MYCCHA = caverealms.config.myccha --0.03 --chance of mycena mushrooms
local WORMCHA = caverealms.config.wormcha --0.03 --chance of glow worms
local GIANTCHA = caverealms.config.giantcha --0.001 -- chance of giant mushrooms
local ICICHA = caverealms.config.icicha --0.035 -- chance of icicles
local FLACHA = caverealms.config.flacha --0.04 --chance of constant flames
local FOUNCHA = caverealms.config.founcha --0.001 --chance of statue + fountain
local FORTCHA = caverealms.config.fortcha --0.0003 --chance of DM Fortresses

local DM_TOP = caverealms.config.dm_top -- -4000 --level at which Dungeon Master Realms start to appear
local DM_BOT = caverealms.config.dm_bot -- -5000 --level at which "" ends
local DEEP_CAVE = caverealms.config.deep_cave -- -7000 --level at which deep cave biomes take over

minetest.register_alias("caverealms:constant_flame", "fire:permanent_flame")

local c_water = minetest.get_content_id("default:water_source")
local c_air = minetest.get_content_id("air")
local c_ice = minetest.get_content_id("default:ice")
local c_thinice = minetest.get_content_id("caverealms:thin_ice")
local c_crystal = minetest.get_content_id("caverealms:glow_crystal")
local c_gem1 = minetest.get_content_id("caverealms:glow_gem")
local c_gem2 = minetest.get_content_id("caverealms:glow_gem_2")
local c_gem3 = minetest.get_content_id("caverealms:glow_gem_3")
local c_gem4 = minetest.get_content_id("caverealms:glow_gem_4")
local c_gem5 = minetest.get_content_id("caverealms:glow_gem_5")
local c_saltgem1 = minetest.get_content_id("caverealms:salt_gem")
local c_saltgem2 = minetest.get_content_id("caverealms:salt_gem_2")
local c_saltgem3 = minetest.get_content_id("caverealms:salt_gem_3")
local c_saltgem4 = minetest.get_content_id("caverealms:salt_gem_4")
local c_saltgem5 = minetest.get_content_id("caverealms:salt_gem_5")
local c_spike1 = minetest.get_content_id("caverealms:spike")
local c_spike2 = minetest.get_content_id("caverealms:spike_2")
local c_spike3 = minetest.get_content_id("caverealms:spike_3")
local c_spike4 = minetest.get_content_id("caverealms:spike_4")
local c_spike5 = minetest.get_content_id("caverealms:spike_5")
local c_moss = minetest.get_content_id("caverealms:stone_with_moss")
local c_lichen = minetest.get_content_id("caverealms:stone_with_lichen")
local c_algae = minetest.get_content_id("caverealms:stone_with_algae")
local c_salt = minetest.get_content_id("caverealms:stone_with_salt")
local c_hcobble = minetest.get_content_id("caverealms:hot_cobble")
local c_gobsidian = minetest.get_content_id("caverealms:glow_obsidian")
local c_gobsidian2 = minetest.get_content_id("caverealms:glow_obsidian_2")
local c_coalblock = minetest.get_content_id("default:coalblock")
local c_desand = minetest.get_content_id("default:desert_sand")
local c_coaldust = minetest.get_content_id("caverealms:coal_dust")
local c_fungus = minetest.get_content_id("caverealms:fungus")
local c_mycena = minetest.get_content_id("caverealms:mycena")
local c_worm = minetest.get_content_id("caverealms:glow_worm")
local c_iciu = minetest.get_content_id("caverealms:icicle_up")
local c_icid = minetest.get_content_id("caverealms:icicle_down")
local c_flame = minetest.get_content_id("fire:permanent_flame")
local c_fountain = minetest.get_content_id("caverealms:s_fountain")
local c_fortress = minetest.get_content_id("caverealms:s_fortress")

local dungeon_floor = function(area, data, ai, vi, bi)
	data[vi] = c_hcobble
	if math.random() < FLACHA then --neverending flames
		data[ai] = c_flame
	elseif math.random() < FOUNCHA and FOUNTAINS then --DM FOUNTAIN
		data[ai] = c_fountain
	elseif math.random() < FORTCHA and FORTRESSES then --DM FORTRESS
		data[ai] = c_fortress
	elseif math.random() < STAGCHA then
		caverealms:stalagmite(vi, area, data)
	elseif math.random() < CRYSTAL then
		caverealms:crystal_stalagmite(vi, area, data, 6)
	end
end

local moss_floor = function(area, data, ai, vi, bi)
	data[vi] = c_moss
	if math.random() < GEMCHA then
		-- gems of random size
		local gems = { c_gem1, c_gem2, c_gem3, c_gem4, c_gem5 }
		local gidx = math.random(1, 12)
		if gidx > 5 then
			gidx = 1
		end
		data[ai] = gems[gidx]
	elseif math.random() < STAGCHA then
		caverealms:stalagmite(vi, area, data)
	elseif math.random() < CRYSTAL then
		caverealms:crystal_stalagmite(vi, area, data, 1)
	end
end

local fungal_floor = function(area, data, ai, vi, bi)
	data[vi] = c_lichen
	if math.random() < MUSHCHA then --mushrooms
		data[ai] = c_fungus
	elseif math.random() < MYCCHA then --mycena mushrooms
		data[ai] = c_mycena
	elseif math.random() < GIANTCHA then --giant mushrooms
		caverealms:giant_shroom(vi, area, data)
	elseif math.random() < STAGCHA then
		caverealms:stalagmite(vi, area, data)
	elseif math.random() < CRYSTAL then
		caverealms:crystal_stalagmite(vi, area, data, 2)
	end
end

local algae_floor = function(area, data, ai, vi, bi)
	data[vi] = c_algae
	if math.random() < STAGCHA then
		caverealms:stalagmite(vi, area, data)
	elseif math.random() < CRYSTAL then
		caverealms:crystal_stalagmite(vi, area, data, 3)
	end
end

local glaciated_floor = function(area, data, ai, vi, bi)
	data[vi] = c_thinice
	data[bi] = c_thinice
	if math.random() < ICICHA then --if glaciated, place icicles
		data[ai] = c_iciu
	elseif math.random() < STAGCHA then
		caverealms:stalagmite(vi, area, data)
	elseif math.random() < CRYSTAL then
		caverealms:crystal_stalagmite(vi, area, data, 4)
	end
end

local deep_glaciated_floor = function(area, data, ai, vi, bi)
	data[vi] = c_ice
	data[bi] = c_ice
	if math.random() < ICICHA then --if glaciated, place icicles
		data[ai] = c_iciu
	elseif math.random() < STAGCHA then
		caverealms:stalagmite(vi, area, data)
	elseif math.random() < CRYSTAL then
		caverealms:crystal_stalagmite(vi, area, data, 5)
	end
end

local salt_floor = function(area, data, ai, vi, bi)
	data[vi] = c_salt
	data[bi] = c_salt
	if math.random() < GEMCHA then
		-- gems of random size
		local gems = { c_saltgem1, c_saltgem2, c_saltgem3, c_saltgem4, c_saltgem5 }
		local gidx = math.random(1, 12)
		if gidx > 5 then
			gidx = 1
		end
		data[ai] = gems[gidx]
	elseif math.random() < STAGCHA then
		caverealms:salt_stalagmite(vi, area, data)
	elseif math.random() < STAGCHA then
		caverealms:stalagmite(vi, area, data)
	elseif math.random() < CRYSTAL then
		caverealms:crystal_stalagmite(vi, area, data, 7)
	end
end

local obsidian_floor = function(area, data, ai, vi, bi)
	if math.random() < 0.5 then
		data[vi] = c_gobsidian
		data[bi] = c_gobsidian
	else
		data[vi] = c_gobsidian2
		data[bi] = c_gobsidian2
	end
	if math.random() < FLACHA then --neverending flames
		data[ai] = c_flame
	elseif math.random() < STAGCHA then
		caverealms:stalagmite(vi, area, data)
	elseif math.random() < CRYSTAL then
		caverealms:crystal_stalagmite(vi, area, data, 8)
	end
end

local coal_floor = function(area, data, ai, vi, bi)
	if math.random() < 0.05 then
		data[vi] = c_coalblock
		data[bi] = c_coalblock
	elseif math.random() < 0.15 then
		data[vi] = c_coaldust
		data[bi] = c_coaldust
	else
		data[vi] = c_desand
		data[bi] = c_desand
	end
	if math.random() < FLACHA * 0.75 then --neverending flames
		data[ai] = c_flame
	elseif math.random() < GEMCHA then
		-- spikes of random size
		local spikes = { c_spike1, c_spike2, c_spike3, c_spike4, c_spike5 }
		local sidx = math.random(1, 12)
		if sidx > 5 then
			sidx = 1
		end
		data[ai] = spikes[sidx]
	elseif math.random() < STAGCHA then
		caverealms:stalagmite(vi, area, data)
	elseif math.random() < CRYSTAL then
		caverealms:crystal_stalagmite(vi, area, data, 9)
	end
end


local standard_ceiling = function(area, data, ai, vi, bi, biome)
	if math.random() < WORMCHA then
		data[vi] = c_worm
		data[bi] = c_worm
		if math.random(2) == 1 then
			local pos = area:position(vi)
			pos.y = pos.y-2
			local bbi = area:indexp(pos)
			data[bbi] = c_worm
			if math.random(2) ==1 then
				pos.y = pos.y-1
				local bbbi = area:indexp(pos)
				data[bbbi] = c_worm
			end
		end
	elseif math.random() < STALCHA then
		caverealms:stalactite(vi, area, data)
	elseif math.random() < CRYSTAL then
		caverealms:crystal_stalactite(vi, area, data, biome)
	end
end

local dungeon_ceiling = function(area, data, ai, vi, bi)
	standard_ceiling(area, data, ai, vi, bi, 6)
end

local moss_ceiling = function(area, data, ai, vi, bi)
	standard_ceiling(area, data, ai, vi, bi, 1)
end

local fungal_ceiling = function(area, data, ai, vi, bi)
	standard_ceiling(area, data, ai, vi, bi, 2)
end

local algae_ceiling = function(area, data, ai, vi, bi)
	standard_ceiling(area, data, ai, vi, bi, 3)
end

local glaciated_ceiling = function(area, data, ai, vi, bi)
	if math.random() < ICICHA then
		data[vi] = c_icid
	end
	standard_ceiling(area, data, ai, vi, bi, 4)
end

local deep_glaciated_ceiling = function(area, data, ai, vi, bi)
	if math.random() < ICICHA then
		data[vi] = c_icid
	end
	standard_ceiling(area, data, ai, vi, bi, 5)
end

local salt_ceiling = function(area, data, ai, vi, bi)
	standard_ceiling(area, data, ai, vi, bi, 7)
end

local obsidian_ceiling = function(area, data, ai, vi, bi)
	standard_ceiling(area, data, ai, vi, bi, 8)
end

local coal_ceiling = function(area, data, ai, vi, bi)
	if math.random() < WORMCHA then
		data[vi] = c_worm
		local bi = area:index(x,y-1,z)
		data[bi] = c_worm
		if math.random(2) == 1 then
			local bbi = area:index(x,y-2,z)
			data[bbi] = c_worm
			if math.random(2) ==1 then
				local bbbi = area:index(x,y-3,z)
				data[bbbi] = c_worm
			end
		end
	end
	if math.random() < STALCHA then
		caverealms:stalactite(x,y,z, area, data)
	end
	if math.random() < CRYSTAL then
		caverealms:crystal_stalactite(x,y,z, area, data, 9)
	end
end


caverealms.biomes = {
	{name = "dungeon master",	y_min = DM_BOT,		y_max = DM_TOP, 	n_biome_min = nil,	n_biome_max = nil,	ceiling_decor = dungeon_ceiling,		floor_decor = dungeon_floor,		fill_node = c_air}, --6
	{name = "moss",				y_min = DEEP_CAVE,	y_max = nil,		n_biome_min = 0,	n_biome_max = 0.5,	ceiling_decor = moss_ceiling,			floor_decor = moss_floor,			fill_node = c_air}, --1
	{name = "fungal",			y_min = DEEP_CAVE,	y_max = nil, 		n_biome_min = nil,	n_biome_max = -0.5,	ceiling_decor = fungal_ceiling,			floor_decor = fungal_floor,			fill_node = c_air}, --2
	{name = "algae",			y_min = DEEP_CAVE,	y_max = nil, 		n_biome_min = -0.5,	n_biome_max = 0,	ceiling_decor = algae_ceiling,			floor_decor = algae_floor,			fill_node = c_air}, --3
	{name = "glaciated",		y_min = nil,		y_max = nil, 		n_biome_min = 0.5,	n_biome_max = 0.7,	ceiling_decor = glaciated_ceiling,		floor_decor = glaciated_floor,		fill_node = c_air}, --4
	{name = "deep glaciated",	y_min = nil,		y_max = nil, 		n_biome_min = 0.7,	n_biome_max =nil,	ceiling_decor = deep_glaciated_ceiling,	floor_decor = deep_glaciated_floor,	fill_node = c_air}, --5
	{name = "salt crystal",		y_min = nil,		y_max = DEEP_CAVE,	n_biome_min = 0,	n_biome_max = 0.5,	ceiling_decor = salt_ceiling,			floor_decor = salt_floor,			fill_node = c_air}, --7
	{name = "glow obsidian",	y_min = nil,		y_max = DEEP_CAVE,	n_biome_min = nil,	n_biome_max = -0.5,	ceiling_decor = obsidian_ceiling,		floor_decor = obsidian_floor,		fill_node = c_air}, --8
	{name = "coal dust",		y_min = nil,		y_max = DEEP_CAVE,	n_biome_min = -0.5,	n_biome_max = 0,	ceiling_decor = coal_ceiling,			floor_decor = coal_floor,			fill_node = c_air}, --9
}