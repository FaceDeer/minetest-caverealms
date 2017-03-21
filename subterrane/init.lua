-- caverealms v.0.8 by HeroOfTheWinds
-- original cave code modified from paramat's subterrain
-- For Minetest 0.4.8 stable
-- Depends default
-- License: code WTFPL

subterrane = {} --create a container for functions and constants

-- set subterrane.mitigate_lava to true to attempt to mitigate lava spilling into the caves
-- set subterrane.get_param2_data to true to make this mod read and set param2 data (shaves a few milliseconds off when you don't, so mods that don't make use of this should leave this unset)

--grab a shorthand for the filepath of the mod
local modpath = minetest.get_modpath(minetest.get_current_modname())

--load companion lua files
dofile(modpath.."/config.lua") --configuration file; holds various constants
dofile(modpath.."/nodes.lua")
dofile(modpath.."/functions.lua") --function definitions

local c_lava = minetest.get_content_id("default:lava_source")
local c_lava_flowing = minetest.get_content_id("default:lava_flowing")
local c_stone = minetest.get_content_id("default:stone")
local c_air = minetest.get_content_id("air")

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

-------------------------------------------------------------------------------------------------------------
-- tcave function

local YMIN = 31000 -- These defaults result in no caves being generated, a safe fallback if things are left unset.
local YMAX = -31000

--cave threshold.:1 = small rare caves, 0.5 = 1/3rd ground volume, 0 = 1/2 ground volume

local tcave_array
local tcave_sort = function(entry1, entry2)
	return tonumber(entry1[1]) > tonumber(entry2[1])
end
function subterrane:set_tcave_array(array)
	table.sort(array, tcave_sort)
	tcave_array = array
	YMAX = tcave_array[1][1]
	YMIN = tcave_array[table.getn(tcave_array)][1]
end

if subterrane.config.ymin and subterrane.config.ymin and subterrane.config.tcave then
	local BLEND = 128 -- Cave blend distance near YMIN, YMAX
	subterrane:set_tcave_array({
		{subterrane.config.ymax, 1.5},
		{subterrane.config.ymax - BLEND, subterrane.config.tcave},
		{subterrane.config.ymin + BLEND, subterrane.config.tcave},
		{subterrane.config.ymin, 1.5},
	})
end

local lerp = function(start, stop, point)
	local percent = (point - start[1]) / (stop[1] - start[1])
	return start[2] + percent * (stop[2] - start[2])
end

local get_tcave = function(y)
	if y < YMIN or y > YMAX then return 1.5 end

	for index, tcave in ipairs(tcave_array) do
		if tcave[1] < y then
			return lerp(tcave_array[index-1], tcave, y)
		end
	end
	
	minetest.debug("should never get here")
	return 1.5
end

---------------------------------------------------------------------------------------------

 -- noise objects
local nobj_cave = nil
local nobj_wave = nil

local data = {}
local data_param2 = {}

-- On generated function

minetest.register_on_generated(function(minp, maxp, seed)
	--if out of range of subterrane limits
	if minp.y > YMAX or maxp.y < YMIN then
		return
	end
	
	-- Create a table of biome ids for use with the biomemap.
	if not subterrane.biome_ids then
		subterrane.biome_ids = {}
		for name, desc in pairs(minetest.registered_biomes) do
			local i = minetest.get_biome_id(desc.name)
			subterrane.biome_ids[i] = desc.name
		end
	end

	--easy reference to commonly used values
	local t1 = os.clock()
	local x1 = maxp.x
	local y1 = maxp.y
	local z1 = maxp.z
	local x0 = minp.x
	local y0 = minp.y
	local z0 = minp.z
	
	print ("[subterrane] chunk minp ("..x0.." "..y0.." "..z0..")") --tell people you are generating a chunk
	
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	vm:get_data(data)
	if subterrane.get_param2_data then
		vm:get_param2_data(data_param2)
	end

	local biomemap = minetest.get_mapgen_object("biomemap")
	
	--mandatory values
	local sidelen = x1 - x0 + 1 --length of a mapblock
	local chulens = {x = sidelen, y = sidelen, z = sidelen} --table of chunk edges
	local chulens2D = {x = sidelen, y = sidelen, z = 1}
	local minposxyz = {x = x0, y = y0, z = z0} --bottom corner
	local minposxz = {x = x0, y = z0} --2D bottom corner
	
	nobj_cave = nobj_cave or minetest.get_perlin_map(np_cave, chulens)
	nobj_wave = nobj_wave or minetest.get_perlin_map(np_wave, chulens)

	local nvals_cave = nobj_cave:get3dMap_flat(minposxyz) --cave noise for structure
	local nvals_wave = nobj_wave:get3dMap_flat(minposxyz) --wavy structure of cavern ceilings and floors
	
	local index_3d = 1 --3D node index
	local index_2d = 1 --2D node index
	
	for z = z0, z1 do -- for each xy plane progressing northwards
		--structure loop, hollows out the cavern
		for y = y0, y1 do -- for each x row progressing upwards
			local tcave = get_tcave(y)

			local vi = area:index(x0, y, z) --current node index
			for x = x0, x1 do -- for each node do

				local biome_name = subterrane.biome_ids[biomemap[index_2d]]
				local biome = minetest.registered_biomes[biome_name]
								
				local fill_node = c_air
				if biome and biome._subterrane_fill_node then
					fill_node = biome._subterrane_fill_node
				end

				if (nvals_cave[index_3d] + nvals_wave[index_3d])/2 > tcave then --if node falls within cave threshold
					data[vi] = fill_node --hollow it out to make the cave
				elseif biome and biome._subterrane_cave_fill_node and data[vi] == c_air then
					data[vi] = biome._subterrane_cave_fill_node
				end
				
				if subterrane.mitigate_lava and (nvals_cave[index_3d] + nvals_wave[index_3d])/2 > tcave - 0.2 then -- Eliminate nearby lava to keep it from spilling in
					if data[vi] == c_lava or data[vi] == c_lava_flowing then
						data[vi] = fill_node
					end
				end
				--increment indices
				index_3d = index_3d + 1
				index_2d = index_2d + 1
				vi = vi + 1
			end
			index_2d = index_2d - sidelen --shift the 2D index back
		end
		index_2d = index_2d + sidelen --shift the 2D index up a layer
	end
	
	local index_3d = 1 --3D node index
	local index_2d = 1 --2D node index

	for z = z0, z1 do -- for each xy plane progressing northwards

		--decoration loop, places nodes on floor and ceiling
		for y = y0, y1 do -- for each x row progressing upwards
			local tcave = get_tcave(y)
			
			local vi = area:index(x0, y, z)
			for x = x0, x1 do -- for each node do
			
				local biome_name = subterrane.biome_ids[biomemap[index_2d]]
				local biome = minetest.registered_biomes[biome_name]
				local fill_node = c_air
				local cave_fill_node = c_air

				if biome then
					-- only check nodes near the edges of caverns
					if math.floor(((nvals_cave[index_3d] + nvals_wave[index_3d])/2)*50) == math.floor(tcave*50) then
						if biome._subterrane_fill_node then
							fill_node = biome._subterrane_fill_node
						end					
						--ceiling
						local ai = area:index(x,y+1,z) --above index
						local bi = area:index(x,y-1,z) --below index
												
						if biome._subterrane_ceiling_decor
							and data[ai] ~= fill_node
							and data[vi] == fill_node
							and y < y1
							then --ceiling
							biome._subterrane_ceiling_decor(area, data, ai, vi, bi, data_param2)
						end
						--ground
						if biome._subterrane_floor_decor
							and data[bi] ~= fill_node
							and data[vi] == fill_node
							and y > y0
							then --ground
							biome._subterrane_floor_decor(area, data, ai, vi, bi, data_param2)
						end
						
					elseif (biome._subterrane_cave_floor_decor or biome._subterrane_cave_ceiling_decor)
							and (nvals_cave[index_3d] + nvals_wave[index_3d])/2 <= tcave --if node falls outside cave threshold
						then
					-- decorate other "native" caves and tunnels
						if biome._subterrane_cave_fill_node then
							cave_fill_node = biome._subterrane_cave_fill_node
							if data[vi] == c_air then
								data[vi] = cave_fill_node
							end
						end

						local ai = area:index(x,y+1,z) --above index
						local bi = area:index(x,y-1,z) --below index
												
						if biome._subterrane_cave_ceiling_decor
							and data[ai] ~= cave_fill_node
							and data[vi] == cave_fill_node
							and y < y1
							then --ceiling
							biome._subterrane_cave_ceiling_decor(area, data, ai, vi, bi, data_param2)
						end
						--ground
						if biome._subterrane_cave_floor_decor
							and data[bi] ~= cave_fill_node
							and data[vi] == cave_fill_node
							and y > y0
							then --ground
							biome._subterrane_cave_floor_decor(area, data, ai, vi, bi, data_param2)
						end
					end	
				end
				index_3d = index_3d + 1
				index_2d = index_2d + 1
				vi = vi + 1
			end
			index_2d = index_2d - sidelen --shift the 2D index back
		end
		index_2d = index_2d + sidelen --shift the 2D index up a layer
	end
	
	--send data back to voxelmanip
	vm:set_data(data)
	if subterrane.get_param2_data then
		vm:set_param2_data(data_param2)
	end
	--calc lighting
	vm:set_lighting({day = 0, night = 0})
	vm:calc_lighting()
	--write it to world
	vm:write_to_map(data)

	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	print ("[subterrane] "..chugent.." ms") --tell people how long
end)
print("[subterrane] loaded!")
