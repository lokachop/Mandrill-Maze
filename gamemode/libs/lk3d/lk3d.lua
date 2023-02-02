--[[
	lk3d.lua

	lokachop's 3D library
	coded by lokachop!
	"The shittest lib ever made!"

	please contact at Lokachop#5862 or lokachop@gmail.com


	ill probably do something else with this lib before im gone
	current idea is a heist game or a ksp clone
]]--

LK3D = LK3D or {}
LK3D.Debug = false
LK3D.Version = 0.7

function LK3D.D_Print(...)
	if not LK3D.Debug then
		return
	end

	MsgC(Color(100, 255, 100), "[LK3D]: ", Color(200, 255, 200), ..., "\n")
end

LK3D.D_Print("Loading LK3D!")

LK3D.Const = {}
LK3D.Const.DEF_UNIVERSE = {["lk3d"] = true, ["objects"] = {}, ["lights"] = {}, ["lightcount"] = 0, ["particles"] = {}}
LK3D.Const.DEF_RT = GetRenderTarget("lk3d_fallback_rt", 800, 600)


LK3D.CamPos = Vector(0, 0, 0)
LK3D.CamAng = Angle(0, 0, 0)
LK3D.WireFrame = false
LK3D.FOV = 90
LK3D.SunDir = Vector(0.75, 1, 1)
LK3D.SunDir:Normalize()
LK3D.ScreenWait = 1 / 60
LK3D.DoDirLighting = true
LK3D.Ortho = false
LK3D.FAR_Z = 200
LK3D.NEAR_Z = .05
LK3D.SHADOW_EXTRUDE = 20
LK3D.SHADOW_INTENSITY = 196
LK3D.DoExpensiveTrace = false
LK3D.TraceReturnTable = false
LK3D.FilterMode = TEXFILTER.LINEAR
LK3D.AmbientCol = Color(0, 0, 0)
LK3D.OrthoParameters = {
	left = 1,
	right = -1,
	top = 1,
	bottom = -1
}

LK3D.CurrUniv = LK3D.Const.DEF_UNIVERSE
LK3D.UniverseStack = {}

LK3D.CurrRenderTarget = LK3D.Const.DEF_RT
LK3D.RenderTargetStack = {}

LK3D.ActiveRenderer = 1 -- this should always be the software renderer

LK3D.Renderers = LK3D.Renderers or {}
include("lk3d_renderer_soft.lua")
include("lk3d_renderer_hard.lua")


function LK3D.SetRenderer(rid)
	if not LK3D.Renderers[rid] then
		LK3D.D_Print("No renderer with id " .. rid .. "!")
		return
	end

	LK3D.ActiveRenderer = rid
end

function LK3D.SetWireFrame(flag)
	LK3D.WireFrame = flag
end

function LK3D.SetFOV(num)
	LK3D.FOV = num
end

function LK3D.SetAmbientCol(col)
	LK3D.AmbientCol = col
end

function LK3D.SetSunDir(vec)
	LK3D.SunDir = vec
	LK3D.SunDir:Normalize()
end

function LK3D.SetDoDirLighting(flag)
	LK3D.DoDirLighting = flag
end

function LK3D.SetOrtho(flag)
	LK3D.Ortho = flag
end

function LK3D.SetOrthoParameters(tbl)
	LK3D.OrthoParameters = tbl
end

function LK3D.SetExpensiveTrace(bool)
	LK3D.DoExpensiveTrace = bool
end

function LK3D.SetTraceReturnTable(bool)
	LK3D.TraceReturnTable = bool
end

function LK3D.SetFilterMode(filtermode)
	LK3D.FilterMode = filtermode
end

-----------------------------
-- Universes
-----------------------------

function LK3D.NewUniverse()
	return {["lk3d"] = true, ["objects"] = {}, ["lights"] = {}, ["lightcount"] = 0, ["particles"] = {}}
end

function LK3D.UniverseSetAtr(uni, k, v)
	uni[k] = v
end

function LK3D.UniverseGet(uni, k)
	return uni[k]
end

function LK3D.PushUniverse(uni)
	LK3D.UniverseStack[#LK3D.UniverseStack + 1] = LK3D.CurrUniv
	LK3D.CurrUniv = uni
end

function LK3D.PopUniverse()
	LK3D.CurrUniv = LK3D.UniverseStack[#LK3D.UniverseStack] or LK3D.Const.DEF_UNIVERSE
	LK3D.UniverseStack[#LK3D.UniverseStack] = nil
end

function LK3D.WipeUniverse()
	LK3D.CurrUniv["objects"] = {}
	LK3D.CurrUniv["lights"] = {}
	LK3D.CurrUniv["lightcount"] = 0
	LK3D.CurrUniv["particles"] = {}
end



-----------------------------
-- Lighting
-----------------------------

function LK3D.AddLight(index, pos, intensity, col, smooth)
	LK3D.CurrUniv["lights"][index] = {pos or Vector(0, 0, 0), intensity or 2, col and {col.r / 255, col.g / 255, col.b / 255} or {1, 1, 1}, (smooth == true) and true or false}
	LK3D.CurrUniv["lightcount"] = LK3D.CurrUniv["lightcount"] + 1
end

function LK3D.RemoveLight(index, pos, intensity)
	if not LK3D.CurrUniv["lights"][index] then
		return
	end

	LK3D.CurrUniv["lights"][index] = nil
	LK3D.CurrUniv["lightcount"] = LK3D.CurrUniv["lightcount"] - 1
end

function LK3D.UpdateLightPos(index, pos)
	if not LK3D.CurrUniv["lights"][index] then
		return
	end
	LK3D.CurrUniv["lights"][index][1] = pos
end

function LK3D.UpdateLightSmooth(index, smooth)
	if not LK3D.CurrUniv["lights"][index] then
		return
	end
	LK3D.CurrUniv["lights"][index][4] = smooth
end

function LK3D.UpdateLightIntensity(index, intensity)
	if not LK3D.CurrUniv["lights"][index] then
		return
	end

	LK3D.CurrUniv["lights"][index][2] = intensity
end

function LK3D.UpdateLightColour(index, col)
	if not LK3D.CurrUniv["lights"][index] then
		return
	end

	LK3D.CurrUniv["lights"][index][3] = col
end

function LK3D.UpdateLight(index, pos, intensity, col)
	if not LK3D.CurrUniv["lights"][index] then
		return
	end
	local pp = LK3D.CurrUniv["lights"][index][1]
	local pi = LK3D.CurrUniv["lights"][index][2]
	local pc = LK3D.CurrUniv["lights"][index][3]

	LK3D.CurrUniv["lights"][index] = {pos and pos or pp, intensity and intensity or pi, col and col or pc}
end

-----------------------------
-- Rendertargets
-----------------------------

function LK3D.PushRenderTarget(rt)
	LK3D.RenderTargetStack[#LK3D.RenderTargetStack + 1] = LK3D.CurrRenderTarget
	LK3D.CurrRenderTarget = rt
end

function LK3D.PopRenderTarget()
	LK3D.CurrRenderTarget = LK3D.RenderTargetStack[#LK3D.RenderTargetStack] or LK3D.Const.DEF_RT
	LK3D.RenderTargetStack[#LK3D.RenderTargetStack] = nil
end


-----------------------------
-- Renderers
-----------------------------

-- renderer should draw the whole scene, z sorted
function LK3D.RenderActiveUniverse()
	local fine, err = pcall(LK3D.Renderers[LK3D.ActiveRenderer].Render)
	if not fine then
		LK3D.D_Print("Error while rendering the whole scene using the \"" .. LK3D.Renderers[LK3D.ActiveRenderer].PrettyName .. "\" renderer; " .. err)
	end
end

-- renderer should return a table with depth on screen
function LK3D.RenderActiveDepthArray()
	local fine, arr = pcall(LK3D.Renderers[LK3D.ActiveRenderer].RenderDepth)
	if not fine then
		LK3D.D_Print("Error while rendering depth using the \"" .. LK3D.Renderers[LK3D.ActiveRenderer].PrettyName .. "\" renderer; " .. arr)
		return
	end

	return arr
end


-- renderer should render an object alone without clearing
function LK3D.RenderObject(obj)
	local fine, err = pcall(LK3D.Renderers[LK3D.ActiveRenderer].RenderObjectAlone, obj)
	if not fine then
		LK3D.D_Print("Error while rendering an object using the \"" .. LK3D.Renderers[LK3D.ActiveRenderer].PrettyName .. "\" renderer; " .. err)
	end
end

-- this should clear the renderer (erase) with rgb colour
function LK3D.RenderClear(r, g, b, a)
	render.PushRenderTarget(LK3D.CurrRenderTarget)
		render.OverrideDepthEnable(true, true)
		render.OverrideAlphaWriteEnable(true, true)
		render.Clear(r, g, b, a or 255, true, true)
		render.OverrideAlphaWriteEnable(false)
		render.OverrideDepthEnable(false)
	render.PopRenderTarget()
end

function LK3D.RenderClearDepth()
	render.PushRenderTarget(LK3D.CurrRenderTarget)
		render.OverrideDepthEnable(true, true)
		render.ClearDepth()
		render.OverrideDepthEnable(false)
	render.PopRenderTarget()
end


function LK3D.RenderQuick(call)
	local ow, oh = ScrW(), ScrH()
	render.SetViewPort(0, 0, LK3D.CurrRenderTarget:Width(), LK3D.CurrRenderTarget:Height())
	cam.Start2D()
	render.PushRenderTarget(LK3D.CurrRenderTarget)
	render.PushFilterMag(LK3D.FilterMode)
	render.PushFilterMin(LK3D.FilterMode)
		local fine, err = pcall(call)
		if not fine then
			LK3D.D_Print("RenderQuick fail; " .. err)
		end
	render.PopFilterMag()
	render.PopFilterMin()
	render.PopRenderTarget()
	cam.End2D()
	render.SetViewPort(0, 0, ow, oh)
end

-----------------------------
-- Translation / Rotation
-----------------------------
function LK3D.SetCamPos(np)
	LK3D.CamPos = np
end

function LK3D.SetCamAng(na)
	LK3D.CamAng = na
end

function LK3D.SetCamPosAng(np, na)
	LK3D.CamPos = np or LK3D.CamPos
	LK3D.CamAng = na or LK3D.CamAng
end


-----------------------------
-- Utils
-----------------------------

LK3D.Utils = LK3D.Utils or {}
LK3D.Utils.MatCache = LK3D.Utils.MatCache or {}
LK3D.Utils.MatCacheTR = LK3D.Utils.MatCacheTR or {}
LK3D.Utils.MatCacheNoZ = LK3D.Utils.MatCacheNoZ or {}
function LK3D.Utils.RTToMaterial(rt, transp, ignorez)
	if not LK3D.Utils.MatCache[rt:GetName()] then
		LK3D.D_Print(rt:GetName() .. " isnt cached, caching!")

		LK3D.Utils.MatCache[rt:GetName()] = CreateMaterial(rt:GetName() .. "_materialized_lk3d", "UnlitGeneric", {
			["$basetexture"] = rt:GetName(),
			["$nocull"] = ignorez and 1 or 0,
			["$ignorez"] = ignorez and 1 or 0,
			["$vertexcolor"] = 1,
			["$alphatest"] = transp and 1 or 0,
		})
	end

	return LK3D.Utils.MatCache[rt:GetName()]
end

function LK3D.Utils.RTToMaterialTL(rt)
	if not LK3D.Utils.MatCacheTR[rt:GetName()] then
		LK3D.D_Print(rt:GetName() .. " isnt cached, caching!")

		LK3D.Utils.MatCacheTR[rt:GetName()] = CreateMaterial(rt:GetName() .. "_materialized_lk3d_transparent", "UnlitGeneric", {
			["$basetexture"] = rt:GetName(),
			--["$nocull"] = 1,
			["$vertexcolor"] = 1,
			["$vertexalpha"] = 1,
		})
	end

	return LK3D.Utils.MatCacheTR[rt:GetName()]
end


function LK3D.Utils.RTToMaterialNoZ(rt, transp)
	if not LK3D.Utils.MatCacheNoZ[rt:GetName()] then
		LK3D.D_Print(rt:GetName() .. " isnt cached, caching!")

		LK3D.Utils.MatCacheNoZ[rt:GetName()] = CreateMaterial("noz_" .. rt:GetName() .. "_materialized_lk3d", "UnlitGeneric", {
			["$basetexture"] = rt:GetName(),
			["$nocull"] = 1,
			["$ignorez"] = 1,
			["$vertexcolor"] = 1,
			--["$alphatest"] = transp and 1 or 0,
		})
	end

	return LK3D.Utils.MatCacheNoZ[rt:GetName()]
end

include("lk3d_modelutils.lua")
include("lk3d_models.lua")

LK3D.ModelInitExtra = LK3D.ModelInitExtra or {}
for k, v in pairs(LK3D.ModelInitExtra) do
	pcall(v) -- fix extern model init load issues
end

include("lk3d_textures.lua")



-- adds a model to the current universe
function LK3D.AddModelToUniverse(index, mdl, pos, ang)
	LK3D.D_Print("Adding \"" .. index .. "\" to universe with model \"" .. (mdl or "cube") .. "\"")
	LK3D.CurrUniv["objects"][index] = {
		mdl = mdl or "cube",
		pos = pos or Vector(0, 0, 0),
		ang = ang or Angle(0, 0, 0),
		scl = Vector(1, 1, 1),
		mat = "white",
		col = Color(255, 255, 255, 255),
		name = index
	}
end

function LK3D.RemoveModelFromUniverse(index)
	LK3D.CurrUniv["objects"][index] = nil
end


function LK3D.SetModelMat(index, mat)
	if not LK3D.CurrUniv["objects"][index] then
		return
	end

	if not LK3D.Textures[mat] then
		LK3D.CurrUniv["objects"][index].mat = "fail"
		return
	end

	LK3D.CurrUniv["objects"][index].mat = mat
end

function LK3D.SetModelCol(index, col)
	if not LK3D.CurrUniv["objects"][index] then
		return
	end

	LK3D.CurrUniv["objects"][index].col = col
end

function LK3D.SetModelPos(index, pos)
	LK3D.CurrUniv["objects"][index].pos = pos
end

function LK3D.SetModelAng(index, ang)
	LK3D.CurrUniv["objects"][index].ang = ang
end
function LK3D.SetModelScale(index, scale)
	LK3D.CurrUniv["objects"][index].scl = scale
end

function LK3D.SetModelModel(index, mdl)
	if not LK3D.Models[mdl] then
		return
	end
	if mdl == LK3D.CurrUniv["objects"][index].mdl then
		return
	end
	LK3D.CurrUniv["objects"][index].mdl = mdl

	if LK3D.CurrUniv["modelCache"] then
		LK3D.CurrUniv["modelCache"][index] = nil
	end
end

function LK3D.SetModelPosAng(index, pos, ang)
	LK3D.CurrUniv["objects"][index].pos = pos or Vector(0, 0, 0)
	LK3D.CurrUniv["objects"][index].ang = ang or Angle(0, 0, 0)
end

function LK3D.SetModelFlag(index, flag, value)
	if flag == nil or value == nil then
		return
	end

	LK3D.CurrUniv["objects"][index][flag] = value
end

function LK3D.SetModelHide(index, bool)
	LK3D.CurrUniv["objects"][index]["RENDER_NOGLOBAL"] = bool
end


include("lk3d_particles.lua")
include("lk3d_debugutils.lua")
include("lk3d_trace.lua")
include("lk3d_bmark.lua")
include("lk3d_rt.lua")
include("lk3d_proctex.lua")
include("lk3d_procmodel.lua")
include("lk3d_musisynth.lua")
include("lk3d_intro.lua")
--stage_dat