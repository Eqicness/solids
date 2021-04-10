local ReplicatedStorage = game:GetService("ReplicatedStorage")

local get = require(game:GetService("ReplicatedStorage").Shared.get)

local solid = get("*s.libs.solid")

local folder = Instance.new("Folder")
folder.Name = "Triangle"
folder.Parent = workspace

local config = ReplicatedStorage.Settings

local m = {}
m.tris = {}

local RADIUS = 500
local SUBDIVIDES = 4

function m.init()
	-- local octahedron = solid.new("octahedron", Vector3.new(0, RADIUS*2, 0), RADIUS, workspace)
	-- octahedron:subdivide(SUBDIVIDES)
	-- octahedron:addNoise(10, 1, 0.5)

	local icosahedron = solid.new("icosahedron", Vector3.new(0, RADIUS*2, 0), RADIUS, workspace)

	icosahedron:subdivide(SUBDIVIDES)

	local scaleVal = config.Scale
	local amplVal = config.Amplitude
	local persVal = config.Persistence
	local octVal = config.Octaves

	for _, val in pairs({scaleVal, amplVal, persVal, octVal}) do
		val.Changed:Connect(function()
			icosahedron:setNoise(scaleVal.Value, amplVal.Value, octVal.Value, persVal.Value)
		end)
	end

	icosahedron:setNoise(scaleVal.Value, amplVal.Value, octVal.Value, persVal.Value)
end

return m