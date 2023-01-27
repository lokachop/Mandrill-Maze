MandMaze = MandMaze or {}

include("shared.lua")
include("cl/mandrillmaze_model.lua")
include("libs/lk3d/lk3d.lua")
include("cl/mandrillmaze.lua")
include("cl_hooks.lua")

local typeStrLUT = {
	[NOTIFY_GENERIC] = "[O] ",
	[NOTIFY_ERROR] = "[X] ",
	[NOTIFY_UNDO] = "[\\] ",
	[NOTIFY_HINT] = "[?] ",
	[NOTIFY_CLEANUP] = "[x] ",
}
function notification.AddLegacy(text, ntype)
	MsgC(Color(255, 255, 64), typeStrLUT[ntype] .. text .. "\n")
end

MandMaze.Snd_mandrill = MandMaze.Snd_mandrill or nil
function GM:InitPostEntity()
	if MandMaze.Snd_mandrill ~= nil then
		MandMaze.Snd_mandrill:Stop()
	end
	LocalPlayer():SetDSP(0)
	MandMaze.Snd_mandrill = CreateSound(game.GetWorld(), "mandrill_maze/mandrill_loop.wav")
	MandMaze.Snd_mandrill:SetSoundLevel(0)
	MandMaze.Snd_mandrill:SetDSP(0)
	MandMaze.Snd_mandrill:Play()
end

--print(MandMaze.Snd_mandrill:IsPlaying())