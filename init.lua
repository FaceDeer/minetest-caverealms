-- caverealms v.0.8 by HeroOfTheWinds
-- original cave code modified from paramat's subterrain
-- For Minetest 0.4.8 stable
-- Depends default
-- License: code WTFPL


caverealms = {} --create a container for functions and constants

--grab a shorthand for the filepath of the mod
local modpath = minetest.get_modpath(minetest.get_current_modname())

--load companion lua files
dofile(modpath.."/config.lua") --configuration file; holds various constants
dofile(modpath.."/crafting.lua") --crafting recipes
dofile(modpath.."/nodes.lua") --node definitions
dofile(modpath.."/functions.lua") --function definitions
dofile(modpath.."/abms.lua") --abm definitions

if caverealms.config.falling_icicles == true then
	dofile(modpath.."/falling_ice.lua") --complicated function for falling icicles
	print("[caverealms] falling icicles enabled.")
end

local FORTRESSES = caverealms.config.fortresses --true | Should fortresses spawn?
local FOUNTAINS = caverealms.config.fountains --true | Should fountains spawn?

-- Parameters

local YMIN = caverealms.config.ymin -- Approximate realm limits.
local YMAX = caverealms.config.ymax
local TCAVE = caverealms.config.tcave --0.5 -- Cave threshold. 1 = small rare caves, 0.5 = 1/3rd ground volume, 0 = 1/2 ground volume
local BLEND = 128 -- Cave blend distance near YMIN, YMAX

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

-- 3D noise for caves

local np_cave = {
	offset = 0,
	scale = 1,
	spread = {x=512, y=256, z=512}, -- squashed 2:1
	seed = 59033,
	octaves = 6,
	persist = 0.63
}

-- 3D noise for wave

local np_wave = {
	offset = 0,
	scale = 1,
	spread = {x=256, y=256, z=256},
	seed = -400000000089,
	octaves = 3,
	persist = 0.67
}

-- 2D noise for biome

local np_biome = {
	offset = 0,
	scale = 1,
	spread = {x=250, y=250, z=250},
	seed = 9130,
	octaves = 3,
	persist = 0.5
}

-- Stuff

subterrain = {}

local yblmin = YMIN + BLEND * 1.5
local yblmax = YMAX - BLEND * 1.5


local c_water = minetest.get_content_id("default:water_source")
local c_river = minetest.get_content_id("default:river_water_source")
local c_lava = minetest.get_content_id("default:lava_source")
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
local c_flame = minetest.get_content_id("caverealms:constant_flame")
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


local biomes = {
	{name = "dungeon master",	y_min = DM_BOT,		y_max = DM_TOP, 	n_biome_min = nil,	n_biome_max = nil,	ceiling_decor = dungeon_ceiling,		floor_decor = dungeon_floor}, --6
	{name = "moss",				y_min = DEEP_CAVE,	y_max = nil,		n_biome_min = 0,	n_biome_max = 0.5,	ceiling_decor = moss_ceiling,			floor_decor = moss_floor}, --1
	{name = "fungal",			y_min = DEEP_CAVE,	y_max = nil, 		n_biome_min = nil,	n_biome_max = -0.5,	ceiling_decor = fungal_ceiling,			floor_decor = fungal_floor}, --2
	{name = "algae",			y_min = DEEP_CAVE,	y_max = nil, 		n_biome_min = -0.5,	n_biome_max = 0,	ceiling_decor = algae_ceiling,			floor_decor = algae_floor}, --3
	{name = "glaciated",		y_min = nil,		y_max = nil, 		n_biome_min = 0.5,	n_biome_max = 0.7,	ceiling_decor = glaciated_ceiling,		floor_decor = glaciated_floor}, --4
	{name = "deep glaciated",	y_min = nil,		y_max = nil, 		n_biome_min = 0.7,	n_biome_max =nil,	ceiling_decor = deep_glaciated_ceiling,	floor_decor = deep_glaciated_floor}, --5
	{name = "salt crystal",		y_min = nil,		y_max = DEEP_CAVE,	n_biome_min = 0,	n_biome_max = 0.5,	ceiling_decor = salt_ceiling,			floor_decor = salt_floor}, --7
	{name = "glow obsidian",	y_min = nil,		y_max = DEEP_CAVE,	n_biome_min = nil,	n_biome_max = -0.5,	ceiling_decor = obsidian_ceiling,		floor_decor = obsidian_floor}, --8
	{name = "coal dust",		y_min = nil,		y_max = DEEP_CAVE,	n_biome_min = -0.5,	n_biome_max = 0,	ceiling_decor = coal_ceiling,			floor_decor = coal_floor}, --9
}

local get_biome = function(y, n_biome)
	for _, biome in ipairs(biomes) do
		if
			(biome.y_max == nil or y < biome.y_max) and
			(biome.y_min == nil or y > biome.y_min) and
			(biome.n_biome_max == nil or n_biome < biome.n_biome_max) and
			(biome.n_biome_min == nil or n_biome > biome.n_biome_min) then
			return biome
		end
	end
	return nil
end

-- On generated function

minetest.register_on_generated(function(minp, maxp, seed)
	--if out of range of caverealms limits
	if minp.y > YMAX or maxp.y < YMIN then
		return --quit; otherwise, you'd have stalagmites all over the place
	end

	--easy reference to commonly used values
	local t1 = os.clock()
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	
	print ("[caverealms] chunk minp ("..x0.." "..y0.." "..z0..")") --tell people you are generating a chunk
	
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	
	--grab content IDs
	local c_air = minetest.get_content_id("air")
	local c_stone = minetest.get_content_id("default:stone")
	
	if (minetest.get_modpath("moontest")) then
		c_air = minetest.get_content_id("moontest:vacuum")
		c_stone = minetest.get_content_id("moontest:stone")
	end
		
	--mandatory values
	local sidelen = x1 - x0 + 1 --length of a mapblock
	local chulens = {x=sidelen, y=sidelen, z=sidelen} --table of chunk edges
	local chulens2D = {x=sidelen, y=sidelen, z=1}
	local minposxyz = {x=x0, y=y0, z=z0} --bottom corner
	local minposxz = {x=x0, y=z0} --2D bottom corner
	
	local nvals_cave = minetest.get_perlin_map(np_cave, chulens):get3dMap_flat(minposxyz) --cave noise for structure
	local nvals_wave = minetest.get_perlin_map(np_wave, chulens):get3dMap_flat(minposxyz) --wavy structure of cavern ceilings and floors
	local nvals_biome = minetest.get_perlin_map(np_biome, chulens2D):get2dMap_flat({x=x0+150, y=z0+50}) --2D noise for biomes (will be 3D humidity/temp later)
	
	local nixyz = 1 --3D node index
	local nixz = 1 --2D node index
	local nixyz2 = 1 --second 3D index for second loop
	
	for z = z0, z1 do -- for each xy plane progressing northwards
		--structure loop, hollows out the cavern
		for y = y0, y1 do -- for each x row progressing upwards
			local tcave --declare variable
			--determine the overall cave threshold
			if y < yblmin then
				tcave = TCAVE + ((yblmin - y) / BLEND) ^ 2
			elseif y > yblmax then
				tcave = TCAVE + ((y - yblmax) / BLEND) ^ 2
			else
				tcave = TCAVE
			end
			local vi = area:index(x0, y, z) --current node index
			for x = x0, x1 do -- for each node do
				if (nvals_cave[nixyz] + nvals_wave[nixyz])/2 > tcave then --if node falls within cave threshold
					data[vi] = c_air --hollow it out to make the cave
				elseif (nvals_cave[nixyz] + nvals_wave[nixyz])/2 > tcave - 0.2 then -- Eliminate nearby lava to keep it from spilling in
					if data[vi] == c_lava then
						data[vi] = c_air
					end
				end
				--increment indices
				nixyz = nixyz + 1
				vi = vi + 1
			end
		end
		
		--decoration loop, places nodes on floor and ceiling
		for y = y0, y1 do -- for each x row progressing upwards
			local tcave --same as above
			if y < yblmin then
				tcave = TCAVE + ((yblmin - y) / BLEND) ^ 2
			elseif y > yblmax then
				tcave = TCAVE + ((y - yblmax) / BLEND) ^ 2
			else
				tcave = TCAVE
			end
			local vi = area:index(x0, y, z)
			for x = x0, x1 do -- for each node do
				
				--determine biome
				local n_biome = nvals_biome[nixz] --make an easier reference to the noise
				local biome = get_biome(y, n_biome)				
				
				if math.floor(((nvals_cave[nixyz2] + nvals_wave[nixyz2])/2)*100) == math.floor(tcave*100) then
					--ceiling
					local ai = area:index(x,y+1,z) --above index
					local bi = area:index(x,y-1,z) --below index
					if data[ai] == c_stone and data[vi] == c_air then --ceiling
						biome.ceiling_decor(area, data, ai, vi, bi)
					end
					--ground
					if data[bi] == c_stone and data[vi] == c_air then --ground
						local ai = area:index(x,y+1,z)
						biome.floor_decor(area, data, ai, vi, bi)
					end
					
				end
				nixyz2 = nixyz2 + 1
				nixz = nixz + 1
				vi = vi + 1
			end
			nixz = nixz - sidelen --shift the 2D index back
		end
		nixz = nixz + sidelen --shift the 2D index up a layer
	end
	
	--send data back to voxelmanip
	vm:set_data(data)
	--calc lighting
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	--write it to world
	vm:write_to_map(data)

	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	print ("[caverealms] "..chugent.." ms") --tell people how long
end)
print("[caverealms] loaded!")
