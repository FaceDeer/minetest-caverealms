-- caverealms v.0.8 by HeroOfTheWinds
-- original cave code modified from paramat's subterrain
-- For Minetest 0.4.8 stable
-- Depends default
-- License: code WTFPL

subterrane = {} --create a container for functions and constants

--grab a shorthand for the filepath of the mod
local modpath = minetest.get_modpath(minetest.get_current_modname())

--load companion lua files
dofile(modpath.."/config.lua") --configuration file; holds various constants
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

-- Stuff

local YMIN = subterrane.config.ymin -- Approximate realm limits.
local YMAX = subterrane.config.ymax
local TCAVE = subterrane.config.tcave --0.5 -- Cave threshold. 1 = small rare caves, 0.5 = 1/3rd ground volume, 0 = 1/2 ground volume
local BLEND = 128 -- Cave blend distance near YMIN, YMAX

local yblmin = YMIN + BLEND * 1.5
local yblmax = YMAX - BLEND * 1.5

-- default mapgen registers an "underground" biome that gets in the way of everything.
subterrane:override_biome({
	name = "underground",
	y_min = YMAX,
	y_max = -113,
	heat_point = 50,
	humidity_point = 50,
})

---------------------------------------------------------------------------------------------

 -- noise objects
local nobj_cave = nil
local nobj_wave = nil 

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
	local data = vm:get_data()

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

				local biome_name = subterrane.biome_ids[biomemap[index_2d]]
				local biome = minetest.registered_biomes[biome_name]
								
				local fill_node = c_air
				if biome and biome._subterrane_fill_node then
					fill_node = biome._subterrane_fill_node
				end

				if (nvals_cave[index_3d] + nvals_wave[index_3d])/2 > tcave then --if node falls within cave threshold
					data[vi] = fill_node --hollow it out to make the cave
				elseif (nvals_cave[index_3d] + nvals_wave[index_3d])/2 > tcave - 0.2 then -- Eliminate nearby lava to keep it from spilling in
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
				-- only check nodes near the edges of caverns
				if math.floor(((nvals_cave[index_3d] + nvals_wave[index_3d])/2)*50) == math.floor(tcave*50) then
					local biome_name = subterrane.biome_ids[biomemap[index_2d]]
					local biome = minetest.registered_biomes[biome_name]
					
					local fill_node = c_air
					if biome and biome._subterrane_fill_node then
						fill_node = biome._subterrane_fill_node
					end
					
					if math.random() < 0.0005 then
						minetest.debug("biome_name", biome_name)
					end
					
					if biome then
						--ceiling
						local ai = area:index(x,y+1,z) --above index
						local bi = area:index(x,y-1,z) --below index
						if biome._subterrane_ceiling_decor and data[ai] == c_stone and data[vi] == fill_node then --ceiling
							biome._subterrane_ceiling_decor(area, data, ai, vi, bi)
						end
						--ground
						if biome._subterrane_floor_decor and data[bi] == c_stone and data[vi] == fill_node then --ground
							local ai = area:index(x,y+1,z)
							biome._subterrane_floor_decor(area, data, ai, vi, bi)
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
	--calc lighting
	vm:set_lighting({day = 0, night = 0})
	vm:calc_lighting()
	--write it to world
	vm:write_to_map(data)

	local chugent = math.ceil((os.clock() - t1) * 1000) --grab how long it took
	print ("[subterrane] "..chugent.." ms") --tell people how long
end)
print("[subterrane] loaded!")
