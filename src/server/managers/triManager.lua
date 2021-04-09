local get = require(game:GetService("ReplicatedStorage").Shared.get)

local solid = get("*s.libs.solid")

local folder = Instance.new("Folder")
folder.Name = "Triangle"
folder.Parent = workspace

local m = {}
m.tris = {}

local RADIUS = 8
local SUBDIVIDES = 2

function m.init()
	local octahedron = solid.new("octahedron", Vector3.new(0, 50, 0), RADIUS, workspace)
	octahedron:showVertices()

	local icosahedron = solid.new("icosahedron", Vector3.new(50, 50, 0), RADIUS, workspace)
	icosahedron:showVertices()

	-- add some random offsets to the shape
	-- todo: join subdivided vertices
	-- adding randomness after subdividing produces errors because of doubled vertices
	octahedron:subdivide(SUBDIVIDES)
	-- octahedron:randomize(0.2)
end

return m