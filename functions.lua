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


--function to create giant 'shrooms. Cap radius works well from about 2-6
function caverealms:giant_shroom(vi, area, data, stem_material, cap_material, gill_material, stem_height, cap_radius)
	local pos = area:position(vi)
	local x = pos.x
	local y = pos.y
	local z = pos.z

	if not caverealms:below_solid(x,y,z,area,data) then
		return
	end
	
	z = z - cap_radius
	--cap
	for k = -cap_radius, cap_radius do
	for l = -cap_radius, cap_radius do
		if k*k + l*l <= cap_radius*cap_radius then
			local vi = area:index(x+k, y+stem_height, z+l)
			data[vi] = cap_material
		end
		if k*k + l*l <= (cap_radius-1)*(cap_radius-1) and (cap_radius-1) > 0 then
			local vi = area:index(x+k, y+stem_height+1, z+l)
			data[vi] = cap_material
			vi = area:index(x+k, y+stem_height, z+l)
			data[vi] = gill_material
		end
		if k*k + l*l <= (cap_radius-2)*(cap_radius-2) and (cap_radius-2) > 0 then
			local vi = area:index(x+k, y+stem_height+2, z+l)
			data[vi] = cap_material
		end
		if k*k + l*l <= (cap_radius-3)*(cap_radius-3) and (cap_radius-3) > 0 then
			local vi = area:index(x+k, y+stem_height+3, z+l)
			data[vi] = cap_material
		end
	end
	end
	--stem
	for j = 0, stem_height do
		local vi = area:index(x, y+j, z)
		data[vi] = stem_material
		if cap_radius > 3 then
			local ai = area:index(x, y+j, z+1)
			data[ai] = stem_material
			ai = area:index(x, y+j, z-1)
			data[ai] = stem_material
			ai = area:index(x+1, y+j, z)
			data[ai] = stem_material
			ai = area:index(x-1, y+j, z)
			data[ai] = stem_material
		end
	end
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

