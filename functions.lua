--CaveRealms functions.lua

--FUNCTIONS--

function caverealms:above_solid(x,y,z,area,data)
	local c_air = minetest.get_content_id("air")
	
	local c_vac
	if (minetest.get_modpath("moontest")) then
		c_vac = minetest.get_content_id("moontest:vacuum")
	else
		c_vac = minetest.get_content_id("air")
	end
	
	local ai = area:index(x,y+1,z-3)
	if data[ai] == c_air or data[ai] == c_vac then
		return false
	else
		return true
	end
end
function caverealms:below_solid(x,y,z,area,data)
	local c_air = minetest.get_content_id("air")
	
	local c_vac
	if (minetest.get_modpath("moontest")) then
		c_vac = minetest.get_content_id("moontest:vacuum")
	else
		c_vac = minetest.get_content_id("air")
	end
	
	local ai = area:index(x,y-1,z-3)
	if data[ai] == c_air or data[ai] == c_vac then
		return false
	else
		return true
	end
end

--stalagmite spawner
function caverealms:stalagmite(vi, area, data, min_height, max_height, base_material, root_material, shaft_material)
	local pos = area:position(vi)
	local x = pos.x
	local y = pos.y
	local z = pos.z

	if not caverealms:below_solid(x,y,z,area,data) then
		return
	end

	local top = math.random(min_height,max_height)
	for j = 0, top do --y
		for k = -3, 3 do
			for l = -3, 3 do
				if j == 0 then
					if k*k + l*l <= 9 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = base_material
					end
				elseif j <= top/5 then
					if k*k + l*l <= 4 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = root_material
					end
				elseif j <= top/5 * 3 then
					if k*k + l*l <= 1 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = shaft_material
					end
				else
					local vi = area:index(x, y+j, z-3)
					data[vi] = shaft_material
				end
			end
		end
	end
end

--stalactite spawner
function caverealms:stalactite(vi, area, data, min_height, max_height, base_material, root_material, shaft_material)
	local pos = area:position(vi)
	local x = pos.x
	local y = pos.y
	local z = pos.z

	if not caverealms:above_solid(x,y,z,area,data) then
		return
	end

	local bot = math.random(-max_height, -min_height) --grab a random height for the stalagmite
	for j = bot, 0 do --y
		for k = -3, 3 do
			for l = -3, 3 do
				if j >= -1 then
					if k*k + l*l <= 9 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = base_material
					end
				elseif j >= bot/5 then
					if k*k + l*l <= 4 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = root_material
					end
				elseif j >= bot/5 * 3 then
					if k*k + l*l <= 1 then
						local vi = area:index(x+k, y+j, z+l-3)
						data[vi] = shaft_material
					end
				else
					local vi = area:index(x, y+j, z-3)
					data[vi] = shaft_material
				end
			end
		end
	end
end


--function to create giant 'shrooms
function caverealms:giant_shroom(vi, area, data)
	local pos = area:position(vi)
	local x = pos.x
	local y = pos.y
	local z = pos.z

	if not caverealms:below_solid(x,y,z,area,data) then
		return
	end

	--as usual, grab the content ID's
	local c_stem = minetest.get_content_id("caverealms:mushroom_stem")
	local c_cap = minetest.get_content_id("caverealms:mushroom_cap")
	local c_gills = minetest.get_content_id("caverealms:mushroom_gills")

	z = z - 5
	--cap
	for k = -5, 5 do
	for l = -5, 5 do
		if k*k + l*l <= 25 then
			local vi = area:index(x+k, y+5, z+l)
			data[vi] = c_cap
		end
		if k*k + l*l <= 16 then
			local vi = area:index(x+k, y+6, z+l)
			data[vi] = c_cap
			vi = area:index(x+k, y+5, z+l)
			data[vi] = c_gills
		end
		if k*k + l*l <= 9 then
			local vi = area:index(x+k, y+7, z+l)
			data[vi] = c_cap
		end
		if k*k + l*l <= 4 then
			local vi = area:index(x+k, y+8, z+l)
			data[vi] = c_cap
		end
	end
	end
	--stem
	for j = 0, 5 do
		for k = -1,1 do
			local vi = area:index(x+k, y+j, z)
			data[vi] = c_stem
			if k == 0 then
				local ai = area:index(x, y+j, z+1)
				data[ai] = c_stem
				ai = area:index(x, y+j, z-1)
				data[ai] = c_stem
			end
		end
	end
end

function caverealms:legacy_giant_shroom(x, y, z, area, data) --leftovers :P
	--as usual, grab the content ID's
	local c_stem = minetest.get_content_id("caverealms:mushroom_stem")
	local c_cap = minetest.get_content_id("caverealms:mushroom_cap")
	
	z = z - 4
	--cap
	for k = -4, 4 do
	for l = -4, 4 do
		if k*k + l*l <= 16 then
			local vi = area:index(x+k, y+5, z+l)
			data[vi] = c_cap
		end
		if k*k + l*l <= 9 then
			local vi = area:index(x+k, y+4, z+l)
			data[vi] = c_cap
			vi = area:index(x+k, y+6, z+l)
			data[vi] = c_cap
		end
		if k*k + l*l <= 4 then
			local vi = area:index(x+k, y+7, z+l)
			data[vi] = c_cap
		end
	end
	end
	--stem
	for j = 0, 4 do
		for k = -1,1 do
			local vi = area:index(x+k, y+j, z)
			data[vi] = c_stem
			if k == 0 then
				local ai = area:index(x, y+j, z+1)
				data[ai] = c_stem
				ai = area:index(x, y+j, z-1)
				data[ai] = c_stem
			end
		end
	end
end

-- Experimental and very geometric function to create giant octagonal crystals in a variety of random directions
-- Uses calculations for points on a sphere, lines in geometric space
-- CURRENTLY USELESS, NOT LIKELY TO BE IMPLEMENTED SOON
function caverealms:octagon(x, y, z, area, data)
	--Grab content id's... diamond is a placeholder
	local c_crys = minetest.get_content_id("default:diamondblock")
	
	local MAX_LEN = 25 --placeholder for a config file constant
	local MIN_LEN = 10 --ditto
	
	local target = {x=0, y=MAX_LEN, z=0} -- 3D space coordinate of the crystal's endpoint
	
	local length = math.random(MIN_LEN, MAX_LEN) --get a random length for the crystal
	local dir1 = math.random(0, 359) -- Random direction in degrees around a circle
	local dir2 = math.random(0, 180) -- Random direction in a semicircle, for 3D location
	
	--OK, so now make a 3D point out of those spherical coordinates...
	target.x = math.ceil(length * math.cos(dir1 * 3.14/180)) --Round it up to make sure it's a nice integer for the coordinate system
	target.z = math.ceil(length * math.sin(dir1 * 3.14/180))
	--Y is also simple, just use dir2.  Note that, due to how these calculations are carried out, this is not a coordinate on a perfect sphere. This is OK for our purposes.
	target.y = math.ceil(length * math.sin(dir2 * 3.14/180))
	
	-- Now, determine if the crystal should go up or down, based on where it is
	if (caverealms:above_solid(x,y,z,area,data)) then
		target.y = target.y * -1
	end
	
	--Bring the coordinates near the area you're generating
	target.x = target.x + x
	target.y = target.y + y
	target.z = target.z + z
	
	
end

local CAVESPAWN = caverealms.config.cavespawn --false by default.  Change to true in order to spawn in the caves when joining as a new player or respawning after death
local spawned = false;
local ydepth = -960;

if (CAVESPAWN) then
	minetest.register_on_newplayer(function(player)
		while spawned ~= true do
			player:setpos({x=0,y=ydepth,z=0})
			--minetest.after(2, function(player, ydepth)
				spawnplayer(player, ydepth)
			--end, player, ydepth)
			ydepth = ydepth - 80
		end
	end)

	minetest.register_on_respawnplayer(function(player)
		while spawned ~= true do
			player:setpos({x=0,y=ydepth,z=0})
			--minetest.after(2, function(player, ydepth)
				spawnplayer(player, ydepth)
			--end, player, ydepth)
			ydepth = ydepth - 80
		end
		return true
	end)
end

-- Spawn player underground
function spawnplayer(player, ydepth)
	
	local xsp
	local ysp
	local zsp
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
	
	local YMIN = caverealms.config.ymin -- Approximate realm limits.
	local YMAX = caverealms.config.ymax
	local TCAVE = caverealms.config.tcave --0.5 -- Cave threshold. 1 = small rare caves, 0.5 = 1/3rd ground volume, 0 = 1/2 ground volume
	local BLEND = 128 -- Cave blend distance near YMIN, YMAX
	
	local yblmin = YMIN + BLEND * 1.5
	local yblmax = YMAX - BLEND * 1.5
	
	for chunk = 1, 64 do
		print ("[caverealms] searching for spawn "..chunk)
		local x0 = 80 * math.random(-32, 32) - 32
		local z0 = 80 * math.random(-32, 32) - 32
		local y0 = ydepth-32
		local x1 = x0 + 79
		local z1 = z0 + 79
		local y1 = ydepth+47

		local sidelen = 80
		local chulens = {x=sidelen, y=sidelen, z=sidelen}
		local minposxyz = {x=x0, y=y0, z=z0}
		local minposxz = {x=x0, y=z0}

		local nvals_cave = minetest.get_perlin_map(np_cave, chulens):get3dMap_flat(minposxyz) --cave noise for structure
		local nvals_wave = minetest.get_perlin_map(np_wave, chulens):get3dMap_flat(minposxyz) --wavy structure of cavern ceilings and floors

		local nixz = 1
		local nixyz = 1
		for z = z0, z1 do
			for y = y0, y1 do
				for x = x0, x1 do
					local n_abscave = math.abs(nvals_cave[nixyz])
					local n_abswave = math.abs(nvals_wave[nixyz])
					
					local tcave --declare variable
					--determine the overal cave threshold
					if y < yblmin then
						tcave = TCAVE + ((yblmin - y) / BLEND) ^ 2
					elseif y > yblmax then
						tcave = TCAVE + ((y - yblmax) / BLEND) ^ 2
					else
						tcave = TCAVE
					end
					
					--if y >= 1 and density > -0.01 and density < 0 then
					if (nvals_cave[nixyz] + nvals_wave[nixyz])/2 > tcave + 0.005 and (nvals_cave[nixyz] + nvals_wave[nixyz])/2 < tcave + 0.015 then --if node falls within cave threshold
						ysp = y + 1
						xsp = x
						zsp = z
						break
					end
					nixz = nixz + 1
					nixyz = nixyz + 1
				end
				if ysp then
					break
				end
				nixz = nixz - 80
			end
			if ysp then
				break
			end
			nixz = nixz + 80
		end
		if ysp then
			break
		end
	end
	print ("[caverealms] spawn player ("..xsp.." "..ysp.." "..zsp..")")
	player:setpos({x=xsp, y=ysp, z=zsp})
	spawned = true
end

--minetest.register_on_newplayer(function(player)
	--spawnplayer(player)
--end)

