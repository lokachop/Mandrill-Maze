LK3D = LK3D or {}

-----------------------------
-- Models
-----------------------------

LK3D.Models = LK3D.Models or {}

function LK3D.GenerateNormals(name, invert)
	LK3D.D_Print("Generating normals for model \"" .. name .. "\"")
	local data = LK3D.Models[name]

	if not data then
		LK3D.D_Print("Model \"" .. name .. "\" doesnt exist!")
		return
	end

	data.normals = {}

	local verts = data.verts
	local ind = data.indices
	for i = 1, #ind do
		local index = ind[i]

		local v1 = Vector(verts[index[1][1]])
		local v2 = Vector(verts[index[2][1]])
		local v3 = Vector(verts[index[3][1]])

		local norm = (v2 - v1):Cross(v3 - v1)
		norm:Normalize()
		if invert then
			norm = -norm
		end
		data["normals"][i] = norm
	end

	data.s_normals = {}
	for i = 1, #data["normals"] do
		local n = data["normals"][i]
		local index = ind[i]


		local id1 = index[1][1]
		data.s_normals[id1] = (data.s_normals[id1] or Vector(0, 0, 0)) + n
		local id2 = index[2][1]
		data.s_normals[id2] = (data.s_normals[id2] or Vector(0, 0, 0)) + n
		local id3 = index[3][1]
		data.s_normals[id3] = (data.s_normals[id3] or Vector(0, 0, 0)) + n
	end


	for i = 1, #data["s_normals"] do
		if data["s_normals"][i] then
			data["s_normals"][i]:Normalize()
		else
			data["s_normals"][i] = Vector(0, 1, 0)
		end
	end

	LK3D.D_Print("Done generating normals for model \"" .. name .. "\"")
end


-- declares a model from the output table of the helper script
-- refer to lk3d-obj_import.lua
function LK3D.DeclareModel(name, data)
	LK3D.Models[name] = data
	LK3D.GenerateNormals(name)
	LK3D.D_Print("Declared model \"" .. name .. "\" with " .. #data.verts .. " verts [TBL]")
end

local function t_copy(tbl)
	local nw = {}
	for k, v in pairs(tbl) do
		if type(v) ~= "table" then
			nw[k] = v
		else
			nw[k] = t_copy(v)
		end
	end

	return nw
end

function LK3D.CopyModel(from, to)
	if not LK3D.Models[from] then
		return
	end

	LK3D.Models[to] = t_copy(LK3D.Models[from])
	LK3D.GenerateNormals(to)
	LK3D.GenTrList(to)
	LK3D.D_Print("Copied model \"" .. from .. "\": to \"" .. to .. "\"")
end



local r_var = 4
function LK3D.DeclareModelFromSource(name, mdl)
	local meshes, bones = util.GetModelMeshes(mdl, 12)
	if not meshes[1] then
		return
	end

	--[[
	for i = 0, #bones do
		local end_idx = i
		while end_idx ~= -1 do
			local bcurr = bones[end_idx]
			if not bcurr.parent then
				break
			end

			local parent = bcurr.parent
			if not bones[parent] then
				break
			end

			bcurr.matrix = bcurr.matrix * bones[parent].matrix
			end_idx = parent
			bcurr = bones[parent]
		end
	end
	]]--

	local data = {}
	data.verts = {}
	data.uvs = {}
	data.indices = {}

	local prevPos = {}

	for i = 1, #meshes[1].triangles, 3 do
		local v1 = meshes[1].triangles[i]
		local v2 = meshes[1].triangles[i + 1]
		local v3 = meshes[1].triangles[i + 2]
		local w1 = meshes[1].triangles[i].weights
		for j = 1, #w1 do
			--print("========")
			local bind = bones[w1[j].bone]
			if bind then
				--print(v1.pos)
				--print(bind.matrix)

				--v1.pos = bind.matrix * v1.pos
				--v2.pos = bind.matrix * v2.pos
				--v3.pos = bind.matrix * v3.pos

				--print(v1.pos)
				--v1.pos:Rotate(bind.matrix:GetAngles())
			end
		end

		--[[
		local v2 = meshes[1].triangles[i + 1]
		local w2 = meshes[1].triangles[i + 1].weights
		for j = 1, #w2 do
			local bind = bones[w2[j].bone]
			if bind then
				v2.pos = bind.matrix * v2.pos
				--v2.pos:Rotate(bind.matrix:GetAngles())
			end
		end

		local v3 = meshes[1].triangles[i + 2]
		local w3 = meshes[1].triangles[i + 2].weights
		for j = 1, #w3 do
			local bind = bones[w3[j].bone]
			if bind then
				v3.pos = bind.matrix * v3.pos
				--v3.pos:Rotate(bind.matrix:GetAngles())
			end
		end
		]]--

		if not v1 or not v2 or not v3 then
			break
		end

		local v1p = v1.pos
		local ovr1, ovr2, ovr3
		if not prevPos[v1p] then
			prevPos[v1p] = {v = #data.verts + 1, uv = #data.uvs + 1}
			ovr1 = {v = #data.verts + 1, uv = #data.uvs + 1}
			data.verts[#data.verts + 1] = Vector(math.Round(v1p.x, r_var), math.Round(v1p.y, r_var), math.Round(v1p.z, r_var))
			data.uvs[#data.uvs + 1] = {math.Round(v1.u, r_var), math.Round(v1.v, r_var)}
		else
			ovr1 = prevPos[v1p]
		end

		local v2p =  v2.pos
		if not prevPos[v2p] then
			prevPos[v2p] = {v = #data.verts + 1, uv = #data.uvs + 1}
			ovr2 = {v = #data.verts + 1, uv = #data.uvs + 1}
			data.verts[#data.verts + 1] = Vector(math.Round(v2p.x, r_var), math.Round(v2p.y, r_var), math.Round(v2p.z, r_var))
			data.uvs[#data.uvs + 1] = {math.Round(v2.u, r_var), math.Round(v2.v, r_var)}
		else
			ovr2 = prevPos[v2p]
		end

		local v3p =  v3.pos
		if not prevPos[v3p] then
			prevPos[v3p] = {v = #data.verts + 1, uv = #data.uvs + 1}
			ovr3 = {v = #data.verts + 1, uv = #data.uvs + 1}
			data.verts[#data.verts + 1] = Vector(math.Round(v3p.x, r_var), math.Round(v3p.y, r_var), math.Round(v3p.z, r_var))
			data.uvs[#data.uvs + 1] = {math.Round(v3.u, r_var), math.Round(v3.v, r_var)}
		else
			ovr3 = prevPos[v3p]
		end

		data.indices[#data.indices + 1] = {{ovr3.v, ovr3.uv}, {ovr2.v, ovr2.uv}, {ovr1.v, ovr1.uv}}
	end

	LK3D.Models[name] = data
	LK3D.GenerateNormals(name)
	LK3D.D_Print("Declared model \"" .. name .. "\" with " .. #data.verts .. " verts [SRC]")
end

-- makes a compressed ver. of model with x name in ur data folder under "lk3d"
function LK3D.CompressModel(name)
	file.CreateDir("lk3d/compmodels")
	local mdl = LK3D.Models[name]

	if not mdl then
		LK3D.D_Print("No model \"" .. name .. "\" to compress!")
	end

	local fnm = "lk3d/compmodels/" .. name .. ".txt"

	file.Write(fnm, "")

	local buffer = ""

	local r_vert = 3
	local r_uv = 4

	-- verts
	buffer = buffer .. "="
	for k, v in ipairs(mdl.verts) do
		buffer = buffer .. math.Round(v.x, r_vert) .. ":" .. math.Round(v.y, r_vert) .. ":" .. math.Round(v.z, r_vert) .. ">"
	end

	-- uvs
	buffer = buffer .. "!"
	for k, v in ipairs(mdl.uvs) do
		buffer = buffer .. math.Round(v[1], r_uv) .. ":" .. math.Round(v[2], r_uv) .. ">"
	end

	-- indices BIG GAIN
	buffer = buffer .. "?"
	for k, v in ipairs(mdl.indices) do
		buffer = buffer .. v[1][1] .. ":" .. v[1][2] .. ":" .. v[2][1] .. ":" .. v[2][2] .. ":" .. v[3][1] .. ":" .. v[3][2] ..  ">"
	end

	-- compress
	buffer = util.Compress(buffer, true)
	buffer = util.Base64Encode(buffer, true)
	file.Write(fnm, buffer)
end

local tn = tonumber
function LK3D.AddModelCompStr(name, str)
	local dstr = util.Decompress(util.Base64Decode(str))
	if not dstr then
		LK3D.D_Print("Failed adding model \"" .. name .. "\" while uncompressing!")
		return
	end


	local s1, s2, s3 = string.match(dstr, "=([%d-.>:]+)!([%d-.>:]+)?([%d-.>:]+)")
	local mdldat = {
		["verts"] = {},
		["uvs"] = {},
		["indices"] = {},
	}

	local verts = string.gmatch(s1, "([-%d.:]+)>")
	for vec in verts do
		local x, y, z = string.match(vec, "([-%d.]+):([-%d.]+):([-%d.]+)")
		mdldat.verts[#mdldat.verts + 1] = Vector(tn(x), tn(y), tn(z))
	end


	local uvs = string.gmatch(s2, "([-%d.:]+)>")
	for uv in uvs do
		local u, v = string.match(uv, "([-%d.]+):([-%d.]+)")
		mdldat.uvs[#mdldat.uvs + 1] = {tn(u), tn(v)}
	end

	local indices = string.gmatch(s3, "([-%d.:]+)>")
	for index in indices do
		local i11, i12, i21, i22, i31, i32 = string.match(index, "([-%d.]+):([-%d.]+):([-%d.]+):([-%d.]+):([-%d.]+):([-%d.]+)")
		mdldat.indices[#mdldat.indices + 1] = {{tn(i11), tn(i12)}, {tn(i21), tn(i22)}, {tn(i31), tn(i32)}}
	end

	LK3D.Models[name] = mdldat
	LK3D.GenerateNormals(name)

	LK3D.D_Print("Declared model \"" .. name .. "\" with " .. #mdldat.verts .. " verts [COMP]")
end





--[[
	LKCOMP docs
	rev1

	start should be "LKC " (4C 4B 43 00 in hex) otherwise its not an lkc file
	after those 4 bytes, the next byte is the revision

	then after that its the number of verts as a ULONG (4bytes)
	
	each vert is three bunched up longs each long is the float * 10000 floored
	(x, y, z)

	after that its the number of UVDATAS as a ULONG (4 bytes)

	each uvdata is 2 ushorts (u * 10000, v * 10000)

	after that its the number of indexes as a ULONG (4 bytes)
	theres 3 indexdata for each vert
	each indexdata is 2 ulongs (index vert, index uv)

	then its an ascii E

]]

local function lkcomp_d_print(...)
	if not LK3D.Debug then
		return
	end

	MsgC(Color(100, 180, 255), "[LKCOMP]: ", Color(200, 200, 255), ..., "\n")
end


local LKCOMP_VER = 1 -- lkcomp revision
local LKCOMP_ENCODERS = {
	[1] = function(name, f_pointer, fname)
		local mdldata = LK3D.Models[name]
		if not mdldata then
			return 1
		end
		f_pointer:Seek(0)

		-- marker
		f_pointer:WriteByte(string.byte("L")) -- L
		f_pointer:WriteByte(string.byte("K")) -- K
		f_pointer:WriteByte(string.byte("C")) -- C
		f_pointer:WriteByte(0x00) -- void

		f_pointer:WriteByte(LKCOMP_VER) -- revision
		f_pointer:WriteULong(#mdldata.verts) -- byte length of vert data
		lkcomp_d_print(#mdldata.verts .. " verts...")

		-- write vert data
		for k, v in ipairs(mdldata.verts) do
			local vec_dat = v

			local calcvar = vec_dat[1]
			f_pointer:WriteLong(math.floor(calcvar * 10000))

			calcvar = vec_dat[2]
			f_pointer:WriteLong(math.floor(calcvar * 10000))

			calcvar = vec_dat[3]
			f_pointer:WriteLong(math.floor(calcvar * 10000))
		end
		lkcomp_d_print("Done vertWriting!")

		f_pointer:WriteULong(#mdldata.uvs) -- byte length of uv data
		lkcomp_d_print(#mdldata.uvs .. " uvs...")

		for k, v in ipairs(mdldata.uvs) do
			local uv_dat = v
			f_pointer:WriteUShort(math.floor(uv_dat[1] * 65534) % 65535)
			f_pointer:WriteUShort(math.floor(uv_dat[2] * 65534) % 65535)
		end
		lkcomp_d_print("Done uvWriting!")

		f_pointer:WriteULong(#mdldata.indices) -- byte length of index data
		lkcomp_d_print(#mdldata.indices .. " indices...")

		for k, v in ipairs(mdldata.indices) do
			local idx_dat = v

			-- we use ushorts cuz low poly models so we dont have to worry about hi poly counts, use legacy compress system for that instead
			f_pointer:WriteUShort(math.floor(idx_dat[1][1]))
			f_pointer:WriteUShort(math.floor(idx_dat[1][2]))

			f_pointer:WriteUShort(math.floor(idx_dat[2][1]))
			f_pointer:WriteUShort(math.floor(idx_dat[2][2]))

			f_pointer:WriteUShort(math.floor(idx_dat[3][1]))
			f_pointer:WriteUShort(math.floor(idx_dat[3][2]))
		end
		lkcomp_d_print("Done indexWriting!")

		-- e to mark end
		f_pointer:WriteByte(string.byte("E")) -- E
		f_pointer:Close()


		local act_name = fname .. ".txt"
		file.Write(fname .. "_raw" .. ".txt", file.Read(act_name, "DATA"))
		file.Write(fname .. "_nolzma" .. ".txt", util.Base64Encode(file.Read(act_name, "DATA"), true))

		file.Write(act_name, util.Base64Encode(util.Compress(file.Read(act_name, "DATA")), true))

	end
}



function LK3D.CompressModelLKC(name)
	LK3D.D_Print("Compressing \"" .. name .. "\" with LKC revision " .. LKCOMP_VER .. "....")
	file.CreateDir("lk3d/lkcomp_models")

	local fnm = "lk3d/lkcomp_models/" .. name
	file.Write(fnm, "")

	local f_pointer = file.Open(fnm .. ".txt", "wb", "DATA")
	if LKCOMP_ENCODERS[LKCOMP_VER] then
		local fine, err = pcall(LKCOMP_ENCODERS[LKCOMP_VER], name, f_pointer, fnm)
		if not fine then
			LK3D.D_Print("Error compressing \"" .. name .. "\" with LKC revision " .. LKCOMP_VER .. ": \"" .. err .. "\"")
		end
	end

	f_pointer:Close()
end


local round_var_rev1 = 4
local LKCOMP_DECODERS = {
	[1] = function(name, f_pointer)
		local mdlDat = {}

		local vertCount = f_pointer:ReadULong()
		lkcomp_d_print(name .. " has " .. vertCount .. " verts...")

		-- read verts..
		mdlDat.verts = {}
		for i = 1, vertCount do
			local vx = math.Round(f_pointer:ReadLong() / 10000, round_var_rev1)
			local vy = math.Round(f_pointer:ReadLong() / 10000, round_var_rev1)
			local vz = math.Round(f_pointer:ReadLong() / 10000, round_var_rev1)

			mdlDat.verts[#mdlDat.verts + 1] = Vector(vx, vy, vz)
		end

		local uvCount = f_pointer:ReadULong()
		lkcomp_d_print(name .. " has " .. uvCount .. " uvs...")

		-- read uvs..
		mdlDat.uvs = {}
		for i = 1, uvCount do
			local u = math.Round(f_pointer:ReadUShort() / 65534, round_var_rev1)
			local v = math.Round(f_pointer:ReadUShort() / 65534, round_var_rev1)

			mdlDat.uvs[#mdlDat.uvs + 1] = {u, v}
		end


		local indexCount = f_pointer:ReadULong()
		lkcomp_d_print(name .. " has " .. indexCount .. " indices...")

		mdlDat.indices = {}
		for i = 1, indexCount do
			local i1_j1 = f_pointer:ReadUShort()
			local i1_j2 = f_pointer:ReadUShort()

			local i2_j1 = f_pointer:ReadUShort()
			local i2_j2 = f_pointer:ReadUShort()

			local i3_j1 = f_pointer:ReadUShort()
			local i3_j2 = f_pointer:ReadUShort()

			mdlDat.indices[#mdlDat.indices + 1] = {
				{i1_j1, i1_j2},
				{i2_j1, i2_j2},
				{i3_j1, i3_j2}
			}
		end

		if string.char(f_pointer:ReadByte()) ~= "E" then
			lkcomp_d_print("Failed to decode \"" .. name .. "\"!")
			return
		end

		LK3D.DeclareModel(name, mdlDat)
	end
}

function LK3D.AddModelLKC(name, data)
	LK3D.D_Print("Decompressing LKCOMP \"" .. name .. "\"...")
	if not data then
		return
	end

	local data_nocomp = util.Decompress(util.Base64Decode(data) or "")

	if not data_nocomp then
		return
	end

	file.Write("lk3d/decomp_temp.txt", data_nocomp)
	local f_pointer = file.Open("lk3d/decomp_temp.txt", "rb", "DATA")


	-- read header
	local head = f_pointer:ReadLong()
	if head ~= 4410188 then
		lkcomp_d_print("Header LKC no match!")
		f_pointer:Close()
		return
	end

	local rev = f_pointer:ReadByte()
	lkcomp_d_print(name .. " is rev" .. rev .. "...")

	if LKCOMP_DECODERS[rev] then
		local fine, err = pcall(LKCOMP_DECODERS[rev], name, f_pointer)
		if not fine then
			LK3D.D_Print("Error decompressing \"" .. name .. "\" with LKC revision " .. rev .. ": \"" .. err .. "\"")
		end
	end

	f_pointer:Close()
end
