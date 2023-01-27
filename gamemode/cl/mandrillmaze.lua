--[[
	coded by lokachop, please contact at Lokachop#5862 or lokachop@gmail.com
]]--

if not LK3D then
	return
end

local rtRender = GetRenderTarget("mandrill_lk3d_canvas" .. ScrW() .. "x" .. ScrH(), ScrW(), ScrH())
function MandMaze.SetupMaterials()
	rtRender = GetRenderTarget("mandrill_lk3d_canvas" .. ScrW() .. "x" .. ScrH(), ScrW(), ScrH())

	local mandrill_mat = Material("mandrill_maze/mandrill.png", "nocull ignorez noclamp smooth")
	LK3D.DeclareTextureFromFunc("mandrill", 512, 512, function()
		render.Clear(255, 0, 0, 255, true, true)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(mandrill_mat)
		surface.DrawTexturedRectUV(0, 0, ScrW(), ScrH(), 0, 1, 1, 0)
	end)
end
MandMaze.SetupMaterials()

MandMaze.UnivMain = LK3D.NewUniverse()
LK3D.PushUniverse(MandMaze.UnivMain)
	LK3D.AddModelToUniverse("mandrill_maze", "mandrill_maze")
	LK3D.SetModelPosAng("mandrill_maze", Vector(0, 0, 0), Angle(0, 0, 90))
	LK3D.SetModelScale("mandrill_maze", Vector(1, 1, 1))
	LK3D.SetModelMat("mandrill_maze", "mandrill")
	LK3D.SetModelFlag("mandrill_maze", "NO_LIGHTING", true)
	LK3D.SetModelFlag("mandrill_maze", "NO_VW_CULLING", true)
	LK3D.SetModelFlag("mandrill_maze", "NO_NORM_CULLING", true)
	LK3D.SetModelFlag("mandrill_maze", "NO_SHADING", true)
	LK3D.SetModelFlag("mandrill_maze", "SHADOW_VOLUME", true)
	LK3D.SetModelFlag("mandrill_maze", "SHADOW_VOLUME_BAKE", true)
	LK3D.SetModelFlag("mandrill_maze", "SHADOW_ZPASS", false)
	LK3D.SetModelFlag("mandrill_maze", "SHADOW_DOSUN", true)
	LK3D.SetModelFlag("mandrill_maze", "CONSTANT", true)


	LK3D.AddModelToUniverse("mandrill_maze_floor", "plane")
	LK3D.SetModelPosAng("mandrill_maze_floor", Vector(-8, 0, 0), Angle(0, 0, 90))
	LK3D.SetModelScale("mandrill_maze_floor", Vector(16, 16, 16))
	LK3D.SetModelMat("mandrill_maze_floor", "white")
	LK3D.SetModelCol("mandrill_maze_floor", Color(128, 128, 128))
	LK3D.SetModelFlag("mandrill_maze_floor", "NO_LIGHTING", true)
	LK3D.SetModelFlag("mandrill_maze_floor", "NO_VW_CULLING", true)
	LK3D.SetModelFlag("mandrill_maze_floor", "NO_NORM_CULLING", true)
	LK3D.SetModelFlag("mandrill_maze_floor", "NO_SHADING", true)
	LK3D.SetModelFlag("mandrill_maze_floor", "CONSTANT", true)
LK3D.PopUniverse()


-- from deepdive
local cam_points = {
	["points"] = {{ -- hand coded :(
		pos = Vector(2, 0.769231, 1),
		dir = Vector(-1, 0, 0),
	}, {
		pos = Vector(1, 0.769231, 1),
		dir = Vector(-1, 0, 0),
	}, {
		pos = Vector(0, 0.769231, 1),
		dir = Vector(-1, 0, 0),
	}, {
		pos = Vector(-1, 0.769231, 1),
		dir = Vector(-1, 0, 0),
	}, {
		pos = Vector(-2, 0.769231 - 1, 1),
		dir = Vector(.25, -1, 0),
	}, {
		pos = Vector(-2, 0.769231 - 2, 1),
		dir = Vector(0, -1, 0),
	}, {
		pos = Vector(-2, 0.769231 - 3, 1),
		dir = Vector(0, -1, 0),
	}, {
		pos = Vector(-3, 0.769231 - 4, 1),
		dir = Vector(-1, -1, 0),
	}, {
		pos = Vector(-4, 0.769231 - 4.35, 1),
		dir = Vector(-1, 0, 0),
	}, {
		pos = Vector(-5, 0.769231 - 4, 1),
		dir = Vector(-1, 1, 0),
	}, {
		pos = Vector(-6, 0.769231 - 3, 1),
		dir = Vector(.25, 1, 0),
	}, {
		pos = Vector(-6, 0.769231 - 2, 1),
		dir = Vector(-.05, 1, 0),
	}, {
		pos = Vector(-6, 0.769231 - 1, 1),
		dir = Vector(0, 1, 0),
	}, {
		pos = Vector(-6, 0.769231 - 0, 1),
		dir = Vector(0, 1, 0),
	}, {
		pos = Vector(-6, 0.769231 + 1, 1),
		dir = Vector(0, 1, 0),
	}, {
		pos = Vector(-7, 0.769231 + 2, 1),
		dir = Vector(-1, -.25, 0),
	}, {
		pos = Vector(-8, 0.769231 + 2, 1),
		dir = Vector(-1, .05, 0),
	}, {
		pos = Vector(-9, 0.769231 + 2, 1),
		dir = Vector(-1, 0, 0),
	}, {
		pos = Vector(-10, 0.769231 + 2, 1),
		dir = Vector(-1, 0, 0),
	}, {
		pos = Vector(-11, 0.769231 + 2, 1),
		dir = Vector(-1, 0, 0),
	}, {
		pos = Vector(-12, 0.769231 + 2, 1),
		dir = Vector(-1, 0, 0),
	}}
}

cam_points.pos_points = {}
cam_points.dir_points = {}

for k2, v2 in ipairs(cam_points.points) do
	cam_points.pos_points[#cam_points.pos_points + 1] = v2.pos
	cam_points.dir_points[#cam_points.dir_points + 1] = v2.dir:GetNormalized()
end

local function updateCamPath()
	local rel_delta = (CurTime() / 8) % 1

	--LK3D.PushUniverse(MandMaze.UnivMain)
	--for k, v in ipairs(cam_points.pos_points) do
	--	LK3D.DebugUtils.Cross(v, 0.2, 0.1, Color(255, 0, 0))
	--
	--	LK3D.DebugUtils.Line(v, v + (cam_points.dir_points[k] / 4), 0.1, Color(255, 255, 0))
	--end
	--LK3D.PopUniverse()

	pos_e = math.BSplinePoint(rel_delta, cam_points.pos_points, 1)
	dir_e = math.BSplinePoint(rel_delta, cam_points.dir_points, 1)

	LK3D.SetCamPos(pos_e)
	LK3D.SetCamAng(dir_e:Angle())
end




LK3D.SetRenderer(LK3D.Const.RENDER_HARD)
LK3D.SetFOV(90)
LK3D.SetWireFrame(false)
LK3D.SetSunDir(Vector(.5, -.5, 1):GetNormalized())
LK3D.FAR_Z = 55
LK3D.NEAR_Z = 0.3 -- fix shadow z fight
function MandMaze.RenderMainCanvas()
	--LK3D.SetCamPos(LocalPlayer():EyePos() / 100)
	--LK3D.SetCamAng(LocalPlayer():EyeAngles())
	updateCamPath()

	LK3D.SetWireFrame(false)
	LK3D.SetRenderer(LK3D.Const.RENDER_HARD)
	LK3D.PushRenderTarget(rtRender)
		LK3D.PushUniverse(MandMaze.UnivMain)
			LK3D.RenderClear(16, 147, 224)
			LK3D.SetAmbientCol(Color(96, 96, 96))

			LK3D.RenderActiveUniverse()
		LK3D.PopUniverse()
	LK3D.PopRenderTarget(rtRender)




	render.PushFilterMag(TEXFILTER.POINT)
	render.PushFilterMin(TEXFILTER.POINT)
		cam.Start2D()
			render.DrawTextureToScreenRect(rtRender, 0, 0, ScrW(), ScrH())
		cam.End2D()
	render.PopFilterMin()
	render.PopFilterMag()
	LK3D.UpdateParticles()
end

local postMake = false
local lastRefresh = os.time()
local canNextRefresh = os.time()
function MandMaze.HandleAutoMatRefresh()
	if not postMake then
		MandMaze.SetupMaterials()
		postMake = true
	end

	if (os.time() - lastRefresh > 2) and os.time() > canNextRefresh then -- generic mat refresher, breaks somewhat on sp cuz of lua pausing
		LK3D.D_Print("LAGSPIKE DETECTED! Refreshing materials...")
		MandMaze.SetupMaterials()
		canNextRefresh = os.time() + 5
	end
	lastRefresh = os.time()
end



