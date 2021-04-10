local get = require(game:GetService("ReplicatedStorage").Shared.get)

local vertex = get("*s.libs.vertex")
local triangle = get("*s.libs.triangle")

local shapes = {}

shapes["octahedron"] = function(solid)
	local s = solid.radius
	local vertices = {
		vertex.new(solid, 0, s, 0),
		vertex.new(solid, 0, -s, 0),
		vertex.new(solid, s, 0, 0),
		vertex.new(solid, -s, 0, 0),
		vertex.new(solid, 0, 0, s),
		vertex.new(solid, 0, 0, -s),
	}
	local triangles = {
		triangle.new(vertices[1], vertices[3], vertices[5], solid._parent),
		triangle.new(vertices[1], vertices[4], vertices[6], solid._parent),
		triangle.new(vertices[1], vertices[4], vertices[5], solid._parent),
		triangle.new(vertices[1], vertices[3], vertices[6], solid._parent),
		triangle.new(vertices[2], vertices[3], vertices[5], solid._parent),
		triangle.new(vertices[2], vertices[4], vertices[6], solid._parent),
		triangle.new(vertices[2], vertices[4], vertices[5], solid._parent),
		triangle.new(vertices[2], vertices[3], vertices[6], solid._parent),
	}

	return vertices, triangles
end

shapes["icosahedron"] = function(solid)
	-- taken from https://devforum.roblox.com/t/procedural-planets/825026. super helpful, thanks
	local X = 0.525731112119133606 * solid.radius
	local Z = 0.850650808352039932 * solid.radius
	local N = 0

	local vertices = {
		vertex.new(solid, -X,N,Z); vertex.new(solid, X,N,Z); vertex.new(solid, -X,N,-Z); vertex.new(solid, X,N,-Z);
		vertex.new(solid, N,Z,X); vertex.new(solid, N,Z,-X); vertex.new(solid, N,-Z,X); vertex.new(solid, N,-Z,-X);
		vertex.new(solid, Z,X,N); vertex.new(solid, -Z,X, N); vertex.new(solid, Z,-X,N); vertex.new(solid, -Z,-X, N);
	};

	local TriSet = {
		{0,4,1};{0,9,4};{9,5,4};{4,5,8};{4,8,1};
		{8,10,1};{8,3,10};{5,3,8};{5,2,3};{2,7,3};
		{7,10,3};{7,6,10};{7,11,6};{11,0,6};{0,1,6};
		{6,1,10};{9,0,11};{9,11,2};{9,2,5};{7,2,11};
	};

	local triangles = {}
	for _, vertIndices in pairs(TriSet) do
		local vertA, vertB, vertC = vertices[vertIndices[1]+1], vertices[vertIndices[2]+1], vertices[vertIndices[3]+1]
		table.insert(triangles, triangle.new(vertA, vertB, vertC, solid._parent))
	end

	return vertices, triangles
end

return shapes