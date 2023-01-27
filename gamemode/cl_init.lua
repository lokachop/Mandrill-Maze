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
local snd_mandrill = nil
function GM:InitPostEntity()
	snd_mandrill = CreateSound(game.GetWorld(), "mandrill_maze/mandrill_loop.wav")
	snd_mandrill:SetSoundLevel(0)
	LocalPlayer():SetDSP(0)
	snd_mandrill:Play()
end