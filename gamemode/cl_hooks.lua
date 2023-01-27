function GM:Think()
	-- lk3d etc
	LK3D.BenchmarkThink()
	LK3D.RaytraceThink()
	LK3D.ProcTex.TextureGenThink()

	MandMaze.HandleAutoMatRefresh()
end

MandMaze = MandMaze or {}
function GM:RenderScene()
	render.Clear(0, 0, 0, 255, true, true)
	MandMaze.RenderMainCanvas()
	LK3D.BenchmarkRender()
	return true
end

function GM:InitPostEntity()

end

function GM:DrawDeathNotice()

end

function GM:StartChat()
	return true
end

local bannedBinds = {
	["messagemode"] = true,
	["messagemode2"] = true,
	["impulse 201"] = true,
	["kill"] = true
}

function GM:PlayerBindPress(ply, bind, pressed, code)
	local tbind = input.TranslateAlias(bind) and input.TranslateAlias(bind) or bind
	if bannedBinds[tbind] then
		return true
	end
end

function GM:HUDShouldDraw(name)
	if name ~= "CHudGMod" then
		return false
	end
end

function GM:OnContextMenuOpen()

end

function GM:OnContextMenuClose()

end

function GM:ScoreboardShow()
	return true
end