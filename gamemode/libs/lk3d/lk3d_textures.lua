LK3D = LK3D or {}
-----------------------------
-- Textures
-----------------------------

LK3D.Textures = LK3D.Textures or {}

function LK3D.FriendlySourceTexture(matsrc)
	local matc = CreateMaterial(matsrc .. "_friendly_", "UnlitGeneric", {
		["$basetexture"] = matsrc,
		["$nodecal"] = 1,
		["$ignorez"] = 1,
		--["$nocull"] = 1,
		["$vertexcolor"] = 1,
		["$vertexalpha"] = 1
	})

	-- from adv. material stool, idk where the github is though
	if (matc.GetString(matc, "$basetexture") ~= matsrc) then
		local m = Material(matsrc)
		matc.SetTexture(matc, "$basetexture", m.GetTexture(m, "$basetexture"))
	end

	return matc
end


function LK3D.UpdateRtEz(rt, call)
	local ow, oh = ScrW(), ScrH()
	render.SetViewPort(0, 0, rt:Width(), rt:Height())
	cam.Start2D()
	render.PushRenderTarget(rt)
	render.PushFilterMag(LK3D.FilterMode)
	render.PushFilterMin(LK3D.FilterMode)
		pcall(call)
	render.PopFilterMag()
	render.PopFilterMin()
	render.PopRenderTarget()
	cam.End2D()
	render.SetViewPort(0, 0, ow, oh)
end


function LK3D.DeclareTextureFromFunc(index, w, h, func, transp, ignorez)
	LK3D.D_Print("declaring texture \"" .. index .. "\" [" .. w .. "x" .. h .. "]; FUNC")
	if not LK3D.Textures[index] then
		local rtg = GetRenderTarget("lk3d_mat_" .. index .. "_rt", w, h)
		local matg = LK3D.Utils.RTToMaterial(rtg, transp, ignorez)

		LK3D.Textures[index] = {
			rt = rtg,
			mat = matg,
			name = index
		}
	end

	local ow, oh = ScrW(), ScrH()
	render.SetViewPort(0, 0, w, h)
	cam.Start2D()
	render.PushRenderTarget(LK3D.Textures[index].rt)
	render.PushFilterMag(LK3D.FilterMode)
	render.PushFilterMin(LK3D.FilterMode)
		render.Clear(0, 0, 0, 0)
		if transp then
			render.OverrideAlphaWriteEnable(true, true)
		end
		local fine, err = pcall(func)
		if not fine then
			LK3D.D_Print("Error while making texture \"" .. index .. "\" [" .. w .. "x" .. h .. "]; " .. err)
		end
		if transp then
			render.OverrideAlphaWriteEnable(false)
		end
	render.PopFilterMag()
	render.PopFilterMin()
	render.PopRenderTarget()
	cam.End2D()
	render.SetViewPort(0, 0, ow, oh)

	-- returning for noobs i guess
	return LK3D.Textures[index]
end

function LK3D.DeclareTextureFromSourceMat(index, w, h, mat, transp)
	LK3D.D_Print("declaring texture \"" .. index .. "\" [" .. w .. "x" .. h .. "]; SMAT")
	if not LK3D.Textures[index] then
		local rtg = GetRenderTarget("lk3d_mat_" .. index .. "_rt", w, h)
		local matg = LK3D.Utils.RTToMaterial(rtg, transp)

		LK3D.Textures[index] = {
			rt = rtg,
			mat = matg,
			name = index
		}
	end

	local matGetWhite = LK3D.FriendlySourceTexture(mat)

	local ow, oh = ScrW(), ScrH()
	cam.Start2D()
	render.PushRenderTarget(LK3D.Textures[index].rt)
	render.SetViewPort(0, 0, w, h)
		if transp then
			render.OverrideAlphaWriteEnable(true, true)
		end
		render.Clear(0, 0, 0, 0)
		render.SetMaterial(matGetWhite)
		render.DrawScreenQuad()
		if transp then
			render.OverrideAlphaWriteEnable(false)
		end
	render.SetViewPort(0, 0, ow, oh)
	render.PopRenderTarget()
	cam.End2D()
end

function LK3D.DeclareTextureFromMatObj(index, w, h, matobj, transp)
	LK3D.D_Print("declaring texture \"" .. index .. "\" [" .. w .. "x" .. h .. "]; SMAT")
	if not LK3D.Textures[index] then
		local rtg = GetRenderTarget("lk3d_mat_" .. index .. "_rt", w, h)
		local matg = LK3D.Utils.RTToMaterial(rtg, transp)

		LK3D.Textures[index] = {
			rt = rtg,
			mat = matg,
			name = index
		}
	end

	local ow, oh = ScrW(), ScrH()


	render.SetViewPort(0, 0, w, h)
	cam.Start2D()
	render.PushRenderTarget(LK3D.Textures[index].rt)
		if transp then
			render.OverrideAlphaWriteEnable(true, true)
		end
		render.Clear(0, 0, 0, 0)
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(matobj)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		if transp then
			render.OverrideAlphaWriteEnable(false)
		end
	render.PopRenderTarget()
	cam.End2D()
	render.SetViewPort(0, 0, ow, oh)
end

function LK3D.CopyTextureRT(name, to)
	local ow, oh = ScrW(), ScrH()
	local trrt = LK3D.GetTextureByIndex(name).rt
	render.SetViewPort(0, 0, trrt:Width(), trrt:Height())
	cam.Start2D()
	render.PushRenderTarget(LK3D.GetTextureByIndex(name).rt)
		render.CopyRenderTargetToTexture(to)
	render.PopRenderTarget()
	cam.End2D()
	render.SetViewPort(0, 0, ow, oh)
end

function LK3D.CopyTexture(from, to)
	local ow, oh = ScrW(), ScrH()
	local t_mat = LK3D.GetTextureByIndex(from).rt
	render.SetViewPort(0, 0, t_mat:Width(), t_mat:Height())
	cam.Start2D()
	render.PushRenderTarget(LK3D.GetTextureByIndex(to).rt)
		render.Clear(128, 128, 255, 255, true, true)
		render.DrawTextureToScreen(t_mat)
	render.PopRenderTarget()
	cam.End2D()
	render.SetViewPort(0, 0, ow, oh)
end


local mat_noz = CreateMaterial("mat_noz_lk3d", "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$nocull"] = 1,
	["$ignorez"] = 1,
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1
})

function LK3D.UpdateTexture(index, func)
	if not LK3D.Textures[index] then
		return
	end

	--if (LK3D.Textures[index].nextUpdate or 0) > CurTime() then
	--	return
	--end

	--LK3D.Textures[index].nextUpdate = CurTime() + LK3D.ScreenWait


	local rt = LK3D.Textures[index].rt

	local w, h = rt:Width(), rt:Height()

	local ow, oh = ScrW(), ScrH()
	render.SetViewPort(0, 0, w, h)
	cam.Start2D()
	render.PushRenderTarget(rt)
		render.SetColorMaterialIgnoreZ()
		draw.NoTexture()
		local fine, err = pcall(func)
		if not fine then
			LK3D.D_Print("Error while updating texture \"" .. index .. "\" [" .. w .. "x" .. h .. "]; " .. err)
		end
	render.PopRenderTarget()
	cam.End2D()
	render.SetViewPort(0, 0, ow, oh)
end




function LK3D.SetupBaseMaterials()
	-- make default mats
	LK3D.DeclareTextureFromFunc("fail", 16, 16, function()
		render.Clear(0, 0, 0, 255)
		surface.SetDrawColor(255, 0, 255)
		surface.DrawRect(0, 0, 8, 8)
		surface.DrawRect(8, 8, 8, 8)
	end)

	LK3D.DeclareTextureFromFunc("checker", 16, 16, function()
		render.Clear(64, 64, 64, 255)
		surface.SetDrawColor(96, 96, 96)
		surface.DrawRect(0, 0, 8, 8)
		surface.DrawRect(8, 8, 8, 8)
	end)


	LK3D.DeclareTextureFromFunc("intro_plane", 1024, 1024, function()
		render.Clear(64, 64, 64, 255)
		surface.SetDrawColor(96, 96, 96)
		surface.DrawRect(0, 0, 512, 512)
		surface.DrawRect(512, 512, 512, 512)
	end)

	LK3D.DeclareTextureFromFunc("intro_box1", 128, 128, function()
		render.Clear(255, 255, 255, 255)
	end)

	LK3D.DeclareTextureFromFunc("intro_loka1", 196, 196, function()
		render.Clear(250, 240, 174, 255)
	end)

	LK3D.DeclareTextureFromFunc("intro_paint_loka3", 64, 64, function()
		render.Clear(38, 65, 38, 0)
	end, true)

	LK3D.DeclareTextureFromFunc("intro_sign_powered2", 96, 96, function()
		render.Clear(255, 255, 255, 0)

		draw.SimpleText("Powered by", "BudgetLabel", ScrW() / 2, ScrH() / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end, true)


	LK3D.DeclareTextureFromFunc("white", 16, 16, function()
		render.Clear(255, 255, 255, 255)
	end)

	local function reScale(p1, p2, p3, p4)
		local c1 = ((p1 / 256) * ScrW())
		local c2 = ((p2 / 256) * ScrW())
		local c3 = ((p3 / 256) * ScrW())
		local c4 = ((p4 / 256) * ScrW())

		return c1, c2, c3, c4
	end

	--local mat_lokaface = Material("lk3d/loka_face_blur_square.png", "nocull ignorez smooth")
	LK3D.DeclareTextureFromFunc("lokaface2_blur4", 1024, 1024, function()
		surface.SetDrawColor(38, 65, 38)
		surface.DrawRect(0, 0, ScrW(), ScrH())

		surface.SetDrawColor(39, 255, 39)
		surface.DrawRect(reScale(72, 40, 25, 118))

		surface.DrawRect(reScale(158, 40, 25, 118))
		surface.DrawRect(reScale(77, 194, 101, 8))

		render.BlurRenderTarget(render.GetRenderTarget(), 12, 8, 6)
	end, false, true)


	LK3D.DeclareTextureFromFunc("lokaface2", 512, 512, function()
		surface.SetDrawColor(38, 65, 38)
		surface.DrawRect(0, 0, ScrW(), ScrH())

		surface.SetDrawColor(39, 255, 39)
		surface.DrawRect(reScale(72, 40, 25, 118))
		surface.DrawRect(reScale(158, 40, 25, 118))
		surface.DrawRect(reScale(77, 194, 101, 8))

		local bl_mat = LK3D.GetTextureByIndex("lokaface2_blur4").mat

		render.OverrideBlend(true, BLEND_ONE, BLEND_ONE, BLENDFUNC_ADD, BLEND_SRC_COLOR, BLEND_DST_ALPHA, BLENDFUNC_ADD)
			surface.SetDrawColor(196, 196, 196)
			surface.SetMaterial(bl_mat)
			for i = 1, 2 do
				surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			end
		render.OverrideBlend(false)
	end)
end
LK3D.SetupBaseMaterials()

function LK3D.GetTextureByIndex(index)
	if not LK3D.Textures[index] then
		return LK3D.Textures["fail"]
	end

	return LK3D.Textures[index]
end