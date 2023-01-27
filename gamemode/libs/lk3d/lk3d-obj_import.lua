file.CreateDir("lk3d")
file.CreateDir("lk3d/exported")

local mdlName = "light_tube"
local doCompact = true
local thrsh_push = 32 -- 32 appends before push
local r_var = 2
local r_var_uv = 2


-- helper script to import objs for lk3d renderer
local objf = file.Read("lk3d/" .. mdlName .. ".obj", "DATA")


if not objf then
    print("not exist :(")
    return
end

local lns = string.gmatch(objf, "[%g% ]+\n")


local verts = {}
local uvs = {}
local indices = {}

for ln in lns do
    if string.sub(ln, 1, 1) == "#" then
        print("comment: " .. string.sub(ln, 1, #ln - 1))
        continue
    end

    if string.sub(ln, 1, 2) == "v " then
        local x, y, z = string.match(ln, "v (%-?[%d.]+) (%-?[%d.]+) (%-?[%d.]+)")
        verts[#verts + 1] = Vector(math.Round(x, r_var), math.Round(y, r_var), math.Round(z, r_var))
    end

    if string.sub(ln, 1, 2) == "vt" then
        local u, v = string.match(ln, "vt (%-?[%d.]+) (%-?[%d.]+)")
        uvs[#uvs + 1] = {u = tonumber(math.Round(u, r_var_uv)), v = tonumber(math.Round(v, r_var_uv))}
    end


    if string.sub(ln, 1, 2) == "f " then
        local vind1, uvind1, vind2, uvind2, vind3, uvind3 = string.match(ln, "f ([%d]+)/([%d]+) ([%d]+)/([%d]+) ([%d]+)/([%d]+)")

        indices[#indices + 1] = {
            {point = vind1, uv = uvind1},
            {point = vind2, uv = uvind2},
            {point = vind3, uv = uvind3}
        }
    end
end



file.Write("lk3d/exported/" .. mdlName .. ".txt", "")
local strBuffer = ""

local function pushChanges()
    file.Append("lk3d/exported/" .. mdlName .. ".txt", strBuffer)
    strBuffer = ""
end


local curr_push = 0
local function app(str)
    strBuffer = strBuffer .. str

    curr_push = curr_push + 1
    if curr_push > thrsh_push then
        pushChanges()
        curr_push = 0
    end
end




local backn = doCompact and "" or "\n"
local tab = doCompact and "" or "    "
local comma = doCompact and "," or ", "
--local seq = doCompact and "=" or " = "

app("-- exported with a helper script written by lokachop (Lokachop#5862)\n")
app("local v = Vector\n")
app(mdlName .. " = {" .. "[\"verts\"] = {" .. backn)
pushChanges()


for k, v in pairs(verts) do
    app(tab .. "v(" .. math.Round(v.x, r_var) .. comma .. math.Round(v.y, r_var) .. comma .. math.Round(v.z, r_var) .. ")," .. backn)
end
app("}" .. comma .. backn)


app("[\"uvs\"] = {" .. backn)
for k, v in pairs(uvs) do
    app(tab .. "{" .. math.Round(v.u, r_var_uv) .. comma .. math.Round(v.v, r_var_uv) .. "}," .. backn)
end
app("}" .. comma .. backn)

app("[\"indices\"] = {" .. backn)
for k, v in pairs(indices) do
    app(tab .. "{" .. backn)
    app(tab .. tab .. "{" .. v[1].point .. comma .. v[1].uv .. "}," .. backn)
    app(tab .. tab .. "{" .. v[2].point .. comma .. v[2].uv .. "}," .. backn)
    app(tab .. tab .. "{" .. v[3].point .. comma .. v[3].uv .. "}" .. backn)
    app(tab .. "}," .. backn)
end
app("}" .. backn)
app("}" .. backn)
pushChanges()
