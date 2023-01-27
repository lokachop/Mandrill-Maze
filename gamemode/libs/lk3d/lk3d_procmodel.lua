LK3D = LK3D or {}



local function dec(n, deci)
	local pow = 10 ^ deci
	return math.floor(n * pow) / pow
end

local pi2 = math.pi * 2
local pi = math.pi
function LK3D.DeclareProcSphere(nm, coli, rowi, szx, szy, uvm)
	local mdat = {}
	mdat["verts"] = {}
	mdat["indices"] = {}
	mdat["uvs"] = {}

	uvm = uvm or 1
	szx = szx or 1
	szy = szy or szx

	for y = 0, coli do
		for x = 0, rowi do
			local dy = y / coli
			local dx = x / rowi

			local sx, sy = math.sin(dx * pi2) * szx, math.cos(dx * pi2) * szx

			local dym = dec(math.sin(dy * pi), 3)
			local subm = -math.cos(dy * pi)

			local vc = Vector(sx * dym, subm * szy, sy * dym)

			if (x % (rowi + 1)) == 0 then
				local prevI = mdat["verts"][#mdat["verts"] - rowi]
				if prevI then
					for i = 0, rowi do
						local cind1 = (#mdat["verts"] + 1) + i
						local cind5 = (#mdat["verts"]) + i


						local cind2 = (#mdat["verts"] - rowi + i) + 0
						local cind3 = (#mdat["verts"] - rowi + i) + 1

						mdat["indices"][#mdat["indices"] + 1] = {
							{cind1, cind1},
							{cind2, cind2},
							{cind3, cind3},
						}
						mdat["indices"][#mdat["indices"] + 1] = {
							{cind5, cind5},
							{cind2, cind2},
							{cind1, cind1},
						}
					end

				end
			end


			mdat["verts"][#mdat["verts"] + 1] = vc
			mdat["uvs"][#mdat["uvs"] + 1] = {dx * uvm, dy * uvm}
		end
	end
	LK3D.Models[nm] = mdat
	LK3D.GenerateNormals(nm)


	local mdldat = LK3D.Models[nm]
	local verts = mdldat.verts
	local ind = mdldat.indices

	for i = 1, #ind do
		local index = ind[i]

		local v1 = Vector(verts[index[1][1]])
		local v2 = Vector(verts[index[2][1]])
		local v3 = Vector(verts[index[3][1]])

		-- sphere?
		-- free smooth normals!

		v1:Normalize()
		v2:Normalize()
		v3:Normalize()

		mdldat.s_normals[index[1][1]] = v1
		mdldat.s_normals[index[2][1]] = v2
		mdldat.s_normals[index[3][1]] = v3
	end
end


function normal_calc_cyl(vert_pos)
	local vn = Vector(vert_pos)
	vn.z = 0
	vn:Normalize()
	return vn
end

function normal_calc_cyl_cap(vert_pos)
	local vn = Vector(vert_pos)
	vn.x = 0
	vn.y = 0
	vn:Normalize()
	return vn
end

function LK3D.DeclareProcCylinder(nm, cyl_itr)
	local mdat = {}
	mdat["verts"] = {}
	mdat["indices"] = {}
	mdat["uvs"] = {}

	local m_verts = mdat["verts"]
	local m_uvs = mdat["uvs"]
	local m_indc = mdat["indices"]

	local caps = {}

	for i = 0, cyl_itr do
		local mv_indx = #m_verts


		--o--o
		--|  |
		--x--o
		local idelta_1 = ((i % cyl_itr) / cyl_itr)
		local idelta_2 = (((i + 1) % cyl_itr) / cyl_itr)


		local mod_var = idelta_1 * pi2
		local xc = math.sin(mod_var)
		local yc = math.cos(mod_var)
		local vert_p1 = (Vector(xc, yc, 1))
		m_verts[mv_indx + 1] = vert_p1
		m_uvs[mv_indx + 1] = {0, 0}


		--o--o
		--|  |
		--o--x
		mod_var = idelta_1 * pi2
		xc = math.sin(mod_var)
		yc = math.cos(mod_var)
		local vert_p2 = (Vector(xc, yc, -1))
		m_verts[mv_indx + 2] = vert_p2
		m_uvs[mv_indx + 2] = {0, 1}

		--0--x
		--|  |
		--o--o
		mod_var = idelta_2 * pi2
		xc = math.sin(mod_var)
		yc = math.cos(mod_var)
		local vert_p3 = (Vector(xc, yc, -1))
		m_verts[mv_indx + 3] = vert_p3
		m_uvs[mv_indx + 3] = {1, 1}

		--x--o
		--|  |
		--o--o
		mod_var = idelta_2 * pi2
		xc = math.sin(mod_var)
		yc = math.cos(mod_var)
		local vert_p4 = (Vector(xc, yc, 1))
		m_verts[mv_indx + 4] = vert_p4
		m_uvs[mv_indx + 4] = {1, 0}

		--\--|
		-- \ |
		--  \|
		m_indc[#m_indc + 1] = {
			{mv_indx + 2, mv_indx + 2},
			{mv_indx + 1, mv_indx + 1},
			{mv_indx + 4, mv_indx + 4},
		}

		--|\
		--| \
		--|__\
		m_indc[#m_indc + 1] = {
			{mv_indx + 2, mv_indx + 2},
			{mv_indx + 4, mv_indx + 4},
			{mv_indx + 3, mv_indx + 3},
		}

		local vert_top = Vector(0, 0, 1) -- 0
		m_verts[mv_indx + 5] = vert_top
		m_uvs[mv_indx + 5] = {.5, .5}

		local vert_bottom = Vector(0, 0, -1) -- 0m
		m_verts[mv_indx + 6] = vert_bottom
		m_uvs[mv_indx + 6] = {.5, .5}


		caps[#m_indc + 1] = true
		m_indc[#m_indc + 1] = {
			{mv_indx + 2, mv_indx + 2},
			{mv_indx + 3, mv_indx + 3},
			{mv_indx + 6, mv_indx + 6},
		}


		caps[#m_indc + 1] = true
		m_indc[#m_indc + 1] = {
			{mv_indx + 4, mv_indx + 4},
			{mv_indx + 1, mv_indx + 1},
			{mv_indx + 5, mv_indx + 5},
		}
	end


	LK3D.Models[nm] = mdat
	LK3D.GenerateNormals(nm)


	local mdldat = LK3D.Models[nm]
	local verts = mdldat.verts
	local ind = mdldat.indices

	for i = 1, #ind do
		local index = ind[i]

		local v1 = Vector(verts[index[1][1]])
		local v2 = Vector(verts[index[2][1]])
		local v3 = Vector(verts[index[3][1]])

		local nc1 = caps[i] and normal_calc_cyl_cap(v1) or normal_calc_cyl(v1)
		local nc2 = caps[i] and normal_calc_cyl_cap(v2) or normal_calc_cyl(v2)
		local nc3 = caps[i] and normal_calc_cyl_cap(v3) or normal_calc_cyl(v3)



		mdldat.s_normals[index[1][1]] = nc1
		mdldat.s_normals[index[2][1]] = nc2
		mdldat.s_normals[index[3][1]] = nc3
	end
end