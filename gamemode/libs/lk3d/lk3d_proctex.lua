LK3D = LK3D or {}
LK3D.ProcTex = LK3D.ProcTex or {}
function LK3D.ProcTex.D_Print(...)
	if not LK3D.Debug then
		return
	end

	MsgC(Color(100, 255, 100), "[LK3D] ", Color(255, 255, 100), "[PROCTEX]: ", Color(200, 255, 200), ..., "\n")
end
LK3D.ProcTex.D_Print("Loading!")


-- https://en.wikipedia.org/wiki/LK3D.ProcTex.Perlin_noise
LK3D.ProcTex.Perlin = LK3D.ProcTex.Perlin or {}
LK3D.ProcTex.Perlin.permutations = {
	151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36,
	103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0,
	26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33, 88, 237, 149, 56,
	87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166,
	77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55,
	46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132,
	187, 208, 89, 18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109,
	198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126,
	255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183,
	170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43,
	172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112,
	104, 218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162,
	241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106,
	157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205,
	93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
}

function LK3D.ProcTex.Perlin.randomGradient(x, y, seed)
	local rnd = LK3D.ProcTex.Perlin.permutations[(((x * 5453764) + (y * 56263) + (seed or 0)) % 256) + 1] % 256
	rnd = rnd / 256
	return Vector(math.sin(rnd), math.cos(rnd))
end
function LK3D.ProcTex.Perlin.dotGridGradient(ix, iy, x, y, seed)
	local grad = LK3D.ProcTex.Perlin.randomGradient(ix, iy, seed)
	return ((x - ix) * grad[1]) + ((y - iy) * grad[2])
end
function LK3D.ProcTex.Perlin.perlin(x, y, seed)
	local x0, y0 = math.floor(x), math.floor(y)
	local x1, y1 = x0 + 1, y0 + 1

	local sx, sy = x - x0, y - y0


	local n0 = LK3D.ProcTex.Perlin.dotGridGradient(x0, y0, x, y, seed)
	local n1 = LK3D.ProcTex.Perlin.dotGridGradient(x1, y0, x, y, seed)
	local ix0 = Lerp(sx, n0, n1)

	n0 = LK3D.ProcTex.Perlin.dotGridGradient(x0, y1, x, y, seed)
	n1 = LK3D.ProcTex.Perlin.dotGridGradient(x1, y1, x, y, seed)
	local ix1 = Lerp(sx, n0, n1)

	return Lerp(sy, ix0, ix1)
end
LK3D.ProcTex.D_Print("Loaded perlin!")


-- https://en.wikipedia.org/wiki/Worley_noise
-- https://thebookofshaders.com/12/
LK3D.ProcTex.Worley = LK3D.ProcTex.Worley or {}
local function v_f2(v)
	return Vector(math.floor(v[1]), math.floor(v[2]))
end
local function v_fract2(v)
	return Vector(v[1] - math.floor(v[1]), v[2] - math.floor(v[2]))
end

local function v_s2(v)
	return Vector(math.sin(v[1]), math.sin(v[2]))
end

function LK3D.ProcTex.Worley.random2(p)
	return v_fract2(v_s2(Vector(p:Dot(Vector(127.1,311.7)), p:Dot(Vector(269.5, 183.3)))) * 43758.5453)
end

function LK3D.ProcTex.Worley.worley(x, y, seed)
	local m_dist = 1
	local st = Vector(x + ((seed or 0) * ScrW()), y + ((seed or 0) * ScrH()))
	st:Div(ScrW(), ScrH())

	local i_st = v_f2(st)
	local f_st = v_fract2(st)
	local ttl = (3 * 3) - 1
	for i = 0, ttl do
		local xc = (i % 3) - 1
		local yc = math.floor(i / 3) - 1
		local neighbor = Vector(xc, yc)

		local point = LK3D.ProcTex.Worley.random2(i_st + neighbor)

		local diff = neighbor + point - f_st

		m_dist = math.min(m_dist, diff:Length())
	end
	return m_dist
end
LK3D.ProcTex.D_Print("Loaded Worley!")


local valuens = {}
function valuens.random2(p)
	return v_fract2(v_s2(Vector(p:Dot(Vector(127.1,311.7)), p:Dot(Vector(269.5, 183.3)))) * 43758.5453)
end

function valuens.noise(x, y, seed)
	local fx = math.floor(x)
	local fy = math.floor(y)

	local ux = math.ceil(x)
	local uy = math.ceil(y)

	local decx = (x - fx)
	local decy = (y - fy)

	local valDL = valuens.random2(Vector(fx, fy))
	local valDR = valuens.random2(Vector(ux, fy))

	local valUL = valuens.random2(Vector(fx, uy))
	local valUR = valuens.random2(Vector(ux, uy))


	local rxu = Lerp(decx, valDL.x, valDR.x)
	local rxd = Lerp(decx, valUL.x, valUR.x)


	local final = Lerp(decy, rxu, rxd)

	return final

end

LK3D.ProcTex.Coros = {}
LK3D.ProcTex.PixelItr = 64

function LK3D.ProcTex.New(name, w, h)
	LK3D.DeclareTextureFromFunc(name, w, h, function()
	end)
end

function LK3D.ProcTex.ApplySolid(name, col_r, g, b)
	LK3D.UpdateTexture(name, function()
		if col_r["r"] then
			render.Clear(col_r.r, col_r.g, col_r.b, 255)
		else
			render.Clear(col_r, g, b, 255)
		end
	end)
end

function LK3D.ProcTex.ApplySource(name, tex)
	local f_t = LK3D.FriendlySourceTexture(tex)
	LK3D.UpdateTexture(name, function()
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(f_t)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end)
end

function LK3D.ProcTex.ApplyPerlinBase(name, sx, sy, mul, seed)
	LK3D.ProcTex.Coros[#LK3D.ProcTex.Coros + 1] = coroutine.create(function()
		local rt = LK3D.Textures[name].rt

		local w, h = rt:Width(), rt:Height()
		local ow, oh = ScrW(), ScrH()
		render.SetViewPort(0, 0, w, h)
		cam.Start2D()
		render.PushRenderTarget(rt)
			render.SetColorMaterialIgnoreZ()
			for i = 0, ScrW() * ScrH() do
				if (i % LK3D.ProcTex.PixelItr) == 0 then
					render.PopRenderTarget()
					cam.End2D()
					render.SetViewPort(0, 0, ow, oh)

					coroutine.yield()

					render.SetViewPort(0, 0, w, h)
					cam.Start2D()
					render.PushRenderTarget(rt)
				end

				local xc, yc = (i % ScrW()), math.floor(i / ScrW())
				local c_val = LK3D.ProcTex.Perlin.perlin(xc / (32 * sx), yc / (32 * sy), seed)
				--c_val = math.abs(c_val) < .05 and 255 or 0
				c_val = c_val * (255 * (mul or 1))
				surface.SetDrawColor(c_val, c_val, c_val, 255)
				surface.DrawRect(xc, yc, 1, 1)
			end
			render.PopRenderTarget()
		cam.End2D()
		render.SetViewPort(0, 0, ow, oh)
		coroutine.yield(1)
	end)
end

function LK3D.ProcTex.PerlinAdditive(name, sx, sy, seed)
	LK3D.ProcTex.Coros[#LK3D.ProcTex.Coros + 1] = coroutine.create(function()
		local rt = LK3D.Textures[name].rt

		local w, h = rt:Width(), rt:Height()
		local ow, oh = ScrW(), ScrH()
		render.SetViewPort(0, 0, w, h)
		cam.Start2D()
		render.PushRenderTarget(rt)
		render.CapturePixels()
			render.SetColorMaterialIgnoreZ()
			for i = 0, ScrW() * ScrH() do
				if (i % LK3D.ProcTex.PixelItr) == 0 then
					render.PopRenderTarget()
					cam.End2D()
					render.SetViewPort(0, 0, ow, oh)

					coroutine.yield()

					render.SetViewPort(0, 0, w, h)
					cam.Start2D()
					render.PushRenderTarget(rt)
					render.CapturePixels()
				end

				local xc, yc = (i % ScrW()), math.floor(i / ScrW())
				local tl_val = LK3D.ProcTex.Perlin.perlin(xc / (32 * sx), yc / (32 * sy), seed)
				local pr, pg, pb = render.ReadPixel(xc, yc)
				surface.SetDrawColor(pr * tl_val, pg * tl_val, pb * tl_val, 255)
				surface.DrawRect(xc, yc, 1, 1)
			end
			render.PopRenderTarget()
		cam.End2D()
		render.SetViewPort(0, 0, ow, oh)
		coroutine.yield(1)
	end)
end



function LK3D.ProcTex.ApplyWorleyBase(name, sx, sy, invert, seed)
	LK3D.ProcTex.Coros[#LK3D.ProcTex.Coros + 1] = coroutine.create(function()
		local rt = LK3D.Textures[name].rt

		local w, h = rt:Width(), rt:Height()
		local ow, oh = ScrW(), ScrH()
		render.SetViewPort(0, 0, w, h)
		cam.Start2D()
		render.PushRenderTarget(rt)
			render.SetColorMaterialIgnoreZ()
			for i = 0, ScrW() * ScrH() do
				if (i % LK3D.ProcTex.PixelItr) == 0 then
					render.PopRenderTarget()
					cam.End2D()
					render.SetViewPort(0, 0, ow, oh)

					coroutine.yield()

					render.SetViewPort(0, 0, w, h)
					cam.Start2D()
					render.PushRenderTarget(rt)
				end

				local xc, yc = (i % ScrW()), math.floor(i / ScrW())
				local c_val = LK3D.ProcTex.Worley.worley(xc / (.25 * sx), yc / (.25 * sy), seed) * .5 + .5
				--c_val = math.abs(c_val) < .05 and 255 or 0
				c_val = invert and math.abs(1 - c_val) or c_val

				c_val = c_val * 255
				surface.SetDrawColor(c_val, c_val, c_val, 255)
				surface.DrawRect(xc, yc, 1, 1)
			end
			render.PopRenderTarget()
		cam.End2D()
		render.SetViewPort(0, 0, ow, oh)
		coroutine.yield(1)
	end)
end

function LK3D.ProcTex.WorleyAdditive(name, sx, sy, sub, seed)
	LK3D.ProcTex.Coros[#LK3D.ProcTex.Coros + 1] = coroutine.create(function()
		local rt = LK3D.Textures[name].rt

		local w, h = rt:Width(), rt:Height()
		local ow, oh = ScrW(), ScrH()
		render.SetViewPort(0, 0, w, h)
		cam.Start2D()
		render.PushRenderTarget(rt)
		render.CapturePixels()
			render.SetColorMaterialIgnoreZ()
			for i = 0, ScrW() * ScrH() do
				if (i % LK3D.ProcTex.PixelItr) == 0 then
					render.PopRenderTarget()
					cam.End2D()
					render.SetViewPort(0, 0, ow, oh)

					coroutine.yield()

					render.SetViewPort(0, 0, w, h)
					cam.Start2D()
					render.PushRenderTarget(rt)
					render.CapturePixels()
				end

				local xc, yc = (i % ScrW()), math.floor(i / ScrW())
				local c_val = LK3D.ProcTex.Worley.worley(xc / (.25 * sx), yc / (.25 * sy), seed) * .5 + .5
				c_val = sub and math.abs(1 - c_val) or c_val
				local pr, pg, pb = render.ReadPixel(xc, yc)
				surface.SetDrawColor(pr * c_val, pg * c_val, pb * c_val, 255)
				surface.DrawRect(xc, yc, 1, 1)
			end
			render.PopRenderTarget()
		cam.End2D()
		render.SetViewPort(0, 0, ow, oh)
		coroutine.yield(1)
	end)
end


function LK3D.ProcTex.Operator(name, call)
	LK3D.ProcTex.Coros[#LK3D.ProcTex.Coros + 1] = coroutine.create(function()
		local rt = LK3D.Textures[name].rt

		local w, h = rt:Width(), rt:Height()
		local ow, oh = ScrW(), ScrH()
		render.SetViewPort(0, 0, w, h)
		cam.Start2D()
		render.PushRenderTarget(rt)
			render.SetColorMaterialIgnoreZ()
			for i = 0, ScrW() * ScrH() do
				if (i % LK3D.ProcTex.PixelItr) == 0 then
					render.PopRenderTarget()
					cam.End2D()
					render.SetViewPort(0, 0, ow, oh)

					coroutine.yield()

					render.SetViewPort(0, 0, w, h)
					cam.Start2D()
					render.PushRenderTarget(rt)
				end

				local xc, yc = (i % ScrW()), math.floor(i / ScrW())
				local c_val = call and call(xc, yc, w, h) or Color(255, 0, 0)
				surface.SetDrawColor(c_val.r, c_val.g, c_val.b, 255)
				surface.DrawRect(xc, yc, 1, 1)
			end
			render.PopRenderTarget()
		cam.End2D()
		render.SetViewPort(0, 0, ow, oh)
		coroutine.yield(1)
	end)
end

function LK3D.ProcTex.ApplyValueBase(name, sx, sy, seed)
	LK3D.ProcTex.Coros[#LK3D.ProcTex.Coros + 1] = coroutine.create(function()
		local rt = LK3D.Textures[name].rt

		local w, h = rt:Width(), rt:Height()
		local ow, oh = ScrW(), ScrH()
		render.SetViewPort(0, 0, w, h)
		cam.Start2D()
		render.PushRenderTarget(rt)
			render.SetColorMaterialIgnoreZ()
			for i = 0, ScrW() * ScrH() do
				if (i % LK3D.ProcTex.PixelItr) == 0 then
					render.PopRenderTarget()
					cam.End2D()
					render.SetViewPort(0, 0, ow, oh)

					coroutine.yield()

					render.SetViewPort(0, 0, w, h)
					cam.Start2D()
					render.PushRenderTarget(rt)
				end

				local xc, yc = (i % ScrW()), math.floor(i / ScrW())
				local c_val = valuens.noise(xc / (.25 * sx), yc / (.25 * sy), seed) * .5 + .5
				c_val = c_val * 255
				surface.SetDrawColor(c_val, c_val, c_val, 255)
				surface.DrawRect(xc, yc, 1, 1)
			end
			render.PopRenderTarget()
		cam.End2D()
		render.SetViewPort(0, 0, ow, oh)
		coroutine.yield(1)
	end)
end


function LK3D.ProcTex.ValueAdditive(name, sx, sy, sub, seed)
	LK3D.UpdateTexture(name, function()
		render.CapturePixels()
		for i = 0, ScrW() * ScrH() do
			local xc, yc = (i % ScrW()), math.floor(i / ScrW())

			local c_val = valuens.noise(xc / (.25 * sx), yc / (.25 * sy), seed) * .5 + .5
			c_val = sub and math.abs(1 - c_val) or c_val

			local pr, pg, pb = render.ReadPixel(xc, yc)
			surface.SetDrawColor(pr * c_val, pg * c_val, pb * c_val, 255)
			surface.DrawRect(xc, yc, 1, 1)
		end
	end)
end



local function blendif(from, to, sx, sy, tresh, seed, call)
	local frt = LK3D.GetTextureByIndex(from).rt
	local fw, fh = frt:Width(), frt:Height()

	cam.Start2D()
	render.PushRenderTarget(frt)
	local ow, oh = ScrW(), ScrH()
	render.SetViewPort(0, 0, fw, fh)
		render.CapturePixels()
	render.PopRenderTarget()
	render.SetViewPort(0, 0, ow, oh)
	cam.End2D()


	LK3D.UpdateTexture(to, function()
		local wm = fw / (ScrW())
		local hm = fh / (ScrH())

		for i = 0, (ScrW() * ScrH()) do
			local xc, yc = (i % ScrW()), math.floor(i / ScrW())

			local c_val = call(xc / sx, yc / sy, seed)

			if c_val > tresh then
				local diff = ((c_val - tresh) / math.abs(1 - tresh)) * 2

				local r_xc = math.floor(xc * wm)
				local r_yc = math.floor(yc * hm)
				local rr, rg, rb = render.ReadPixel(r_xc, r_yc)
				render.SetColorMaterialIgnoreZ()
				surface.SetDrawColor(rr, rg, rb, 255 * diff)
				surface.DrawRect(xc, yc, 1, 1)
			end
		end
	end)
end

function LK3D.ProcTex.PerlinMask(from, to, sx, sy, treshold, seed)
	blendif(from, to, 32 * sx, 32 * sy, treshold, seed, LK3D.ProcTex.Perlin.perlin)
end

function LK3D.ProcTex.WorleyMask(from, to, sx, sy, treshold, seed)
	blendif(from, to, .25 * sx, .25 * sy, treshold, seed, LK3D.ProcTex.Worley.worley)
end


function LK3D.ProcTex.TextureGenThink()
	LK3D.ProcTex.PixelItr = (196 / #LK3D.ProcTex.Coros)

	local toRem = {}
	for k, v in ipairs(LK3D.ProcTex.Coros) do
		local _, ret = coroutine.resume(v)
		if ret == 1 then
			toRem[#toRem + 1] = k
		end
	end

	for k, v in ipairs(toRem) do
		LK3D.ProcTex.Coros[v] = nil
	end
end


-- TODO: Value noise (https://en.wikipedia.org/wiki/Value_noise)
-- TODO: Simplex noise (https://en.wikipedia.org/wiki/Simplex_noise)
-- TODO: Distortions (rotate, scale, persp, fractal distort)
-- TODO: Localized copying
-- TODO: algorithms for regular textures (bricks, tiles, sewers, etc)
-- TODO: edge det. algorithm (https://en.wikipedia.org/wiki/Edge_detection)



-- LK3D.ProcTex.Perlin uses: https://redirect.cs.umbc.edu/~olano/s2002c36/ch02.pdf


LK3D.ProcTex.New("LK3D.ProcTex.Perlintest", 64, 64)
--LK3D.ProcTex.ApplyLK3D.ProcTex.PerlinBase("LK3D.ProcTex.Perlintest", .5, .5, 1, math.random(0, 1243))

LK3D.ProcTex.New("worleytest", 64, 64)
--LK3D.ProcTex.ApplyWorleyBase("worleytest", 1, 1, 1, math.random(0, 1243))



LK3D.ProcTex.New("submarine_rust", 256, 256)
LK3D.ProcTex.ApplySource("submarine_rust", "metal/metalfloor005a")

LK3D.ProcTex.New("submarine_rusted", 256, 256)
LK3D.ProcTex.ApplySource("submarine_rusted", "metal/metalpipe010a")
--LK3D.ProcTex.LK3D.ProcTex.PerlinMask("submarine_rust", "submarine_rusted", 1, 1, .3, math.random(0, 1243))

LK3D.ProcTex.New("blood_ocean", 256, 256)
LK3D.ProcTex.ApplySolid("blood_ocean", Color(255, 0, 0))
--LK3D.ProcTex.WorleyAdditive("blood_ocean", .5, .5, false, math.random(0, 1243))
--LK3D.ProcTex.LK3D.ProcTex.PerlinAdditive("blood_ocean", .25, .25, math.random(0, 1243))



LK3D.ProcTex.New("blend_orange", 256, 256)
LK3D.ProcTex.ApplySource("blend_orange", "dev/dev_measuregeneric01")

LK3D.ProcTex.New("blend_show", 256, 256)
LK3D.ProcTex.ApplySource("blend_show", "dev/dev_measuregeneric01b")
--LK3D.ProcTex.LK3D.ProcTex.PerlinMask("blend_orange", "blend_show", 2, 2, .45, math.random(0, 1243))

