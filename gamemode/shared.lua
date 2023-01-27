GM.Name = "Mandrill Maze"
GM.Description = "Mandrill Maze"
GM.Author = "Lokachop"
GM.Email = "Lokachop#5862"
GM.Website = "lokachop@gmail.com"
MandMaze = MandMaze or {}

function GM:StartCommand(ply, mvd) -- no jumping, etc
	mvd:ClearMovement()
	mvd:ClearButtons()
end


function GM:EntityEmitSound(data)
	if data.OriginalSoundName ~= "mandrill_maze/mandrill_loop.wav" then
		return false
	end
end