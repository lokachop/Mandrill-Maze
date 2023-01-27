AddCSLuaFile("cl_hooks.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function GM:Think()
end

function GM:PlayerNoClip(ply, state)
	return GetConVar("sbox_noclip") and true or false
end

function GM:PlayerSwitchFlashlight(ply, state)
	return true
end

function GM:CanPlayerSuicide(ply)
	return false
end

function GM:InitPostEntity()
end

function GM:PlayerConnect()
end

function GM:PlayerSwitchFlashlight()
	return false
end

local function recur_load_libs(path)
	print("loading libs on path " .. path .. "*")
	local files, dirs = file.Find(path .. "*", "LUA")

	for k, v in pairs(files) do
		print("adding; " .. path .. v)
		AddCSLuaFile(path .. v)
	end

	for k, v in pairs(dirs) do
		recur_load_libs(path .. v .. "/")
	end
end


function GM:Initialize()
	recur_load_libs(engine.ActiveGamemode() .. "/gamemode/" .. "libs/")
	recur_load_libs(engine.ActiveGamemode() .. "/gamemode/" .. "cl/")
	hook.Call("Initialize")
end
recur_load_libs(engine.ActiveGamemode() .. "/gamemode/" .. "libs/")
recur_load_libs(engine.ActiveGamemode() .. "/gamemode/" .. "cl/")

function GM:PlayerSetModel(ply)
	ply:SetModel("models/player/odessa.mdl")
end