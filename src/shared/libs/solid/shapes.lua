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
	local GOLDEN_RATIO = (1+math.sqrt(5))/2

	-- used for determining the ratios of the icosahedron.
	local FULL = 0.8506509 -- GOLDEN_RATIO/math.sqrt(GOLDEN_RATIO^2 + 1)
	local SPACE = FULL/GOLDEN_RATIO
	-- FULL^2 + SPACE^2 = 1, pythag theorum so that distance to any vertex is 1 (1*RADIUS)

	local vertices = {
		vertex.new(solid, 0, 0, 0)
	}
	local triangles = {}

	local function p()
		return Vector3.new()
	end
	
	local function _()
		local triPoints = {}
	
		-- generates 12 sides
	
		local offsets = {
			CFrame.new(0, FULL, SPACE),
			CFrame.new(0, FULL, -SPACE),
			CFrame.new(FULL, SPACE, 0)
		}
		local origin = CFrame.new()
	
		
		for g = -1, 1, 2 do
			for i = 1, 6 do
				local points = {}
				for _, offset in pairs(offsets) do
					table.insert(points, p((origin*offset).Position))
				end
				table.insert(triPoints, points)
				origin = origin*CFrame.Angles(math.pi/2*(i%2==0 and 1 or -1), math.pi/2*(i%2==0 and 1 or -1)*g, 0)
			end
			origin = CFrame.Angles(0, math.pi, math.pi)
		end
	
		-- generates remaining 8 corner sides
		offsets = {
			CFrame.new(0, FULL, SPACE),
			CFrame.new(FULL, SPACE, 0),
			CFrame.new(SPACE, 0, FULL)
		}
		origin = CFrame.new()
	
		for i = 1, 4 do
			local points = {}
			for _, offset in pairs(offsets) do
				table.insert(points, p((origin*offset).Position))
			end
			table.insert(triPoints, points)
			origin = origin*CFrame.Angles(math.pi, math.pi*(i%2==0 and 0 or 1), math.pi*(i%2==0 and 1 or 0))
		end
	
		offsets = {
			CFrame.new(0, SPACE, FULL),
			CFrame.new(SPACE, FULL, 0),
			CFrame.new(FULL, 0, SPACE)
		}
		origin = CFrame.Angles(math.pi/2, 0, 0)
	
		for i = 1, 4 do
			local points = {}
			for _, offset in pairs(offsets) do
				table.insert(points, p((origin*offset).Position))
			end
			table.insert(triPoints, points)
			origin = origin*CFrame.Angles(-math.pi, math.pi*(i%2==0 and 1 or 0), math.pi*(i%2==0 and 0 or 1))
		end
	
		return triPoints
	end

	return vertices, triangles
end

return shapes