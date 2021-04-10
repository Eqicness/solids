local get = require(game:GetService("ReplicatedStorage").Shared.get)

local maid = get("*s.libs.maid")
local event = get("*s.libs.event")
local vertex = get("*s.libs.vertex")
local triangle = get("*s.libs.triangle")
local shapes = require(script.shapes)

local solid = {}
solid.__index = solid

function solid:Destroy()
	self.maid:Destroy()
end

function solid:showVertices()
	for _, vert in pairs(self.vertices) do
		vert:show()
	end
end

function solid:hideVertices()
	for _, vert in pairs(self.vertices) do
		vert:hide()
	end
end

function solid:newVertex(pos)
	for _, vert in pairs(self.vertices) do
		if vert.position == pos or vert.position:FuzzyEq(pos) then
			return vert
		end
	end

	return vertex.new(self, pos)
end

function solid:subdivideTriangle(tri, levels)
	local newVertices = {}
	newVertices[1] = (tri.vertices[1].position+tri.vertices[2].position)/2
	newVertices[2] = (tri.vertices[2].position+tri.vertices[3].position)/2
	newVertices[3] = (tri.vertices[1].position+tri.vertices[3].position)/2

	-- project vertices onto sphere
	-- this slightly distorts triangles, losing equilateralism (is that even a word)
	for i, pos in pairs(newVertices) do
		pos = pos.Unit * self.radius
		newVertices[i] = self:newVertex(pos)
	end

	return newVertices, {
		triangle.new(newVertices[1], newVertices[2], newVertices[3], self._parent),		-- middle
		triangle.new(tri.vertices[1], newVertices[1], newVertices[3], self._parent),	-- top
		triangle.new(tri.vertices[2], newVertices[1], newVertices[2], self._parent),	-- bottom left
		triangle.new(tri.vertices[3], newVertices[2], newVertices[3], self._parent),	-- bottom right
	}
end

function solid:_subdivide()
	local allNewTris = {}
	for i, oldTri in pairs(self.triangles) do
		local newVerts, newTris = self:subdivideTriangle(oldTri)
		for _, vert in pairs(newVerts) do
			if not table.find(self.vertices, vert) then
				table.insert(self.vertices, vert)
			end
		end
		for _, tri in pairs(newTris) do
			table.insert(allNewTris, tri)
		end
		oldTri:Destroy()
		self.triangles[i] = nil
	end
	self.triangles = allNewTris
end

function solid:subdivide(levels)
	for _ = 1, (levels or 1) do
		self:_subdivide()
	end
	for _, tri in pairs(self.triangles) do
		tri:refresh()
	end
end

function solid:setOrigin(v3)
	self.origin = v3
	self.moved:Fire()
end

function solid:setNoise(scale, amplitude, octaves, persistence)
	local lowest = 100
	local highest = -100
	for _, vert in pairs(self.vertices) do
		if vert.originalPosition then
			-- bypassing setPos because it's going to be used again below. no need to do all the refreshes.
			vert.position = vert.originalPosition
		end
		
		if amplitude > 0 then
			-- Noise
			scale = math.min(scale or 0.5, 1)
			amplitude = amplitude or 10
			octaves = math.max(octaves or 1, 1)
			persistence = persistence or 0.5

			local pos = vert:getWorldPosition()
			-- long/lat method produces a seam because of the range of atan2
			-- local pos = vert.position
			-- local long, lat = math.deg(math.atan2(pos.Unit.Z, pos.Unit.X)), math.deg(math.acos(Vector3.new(0, 1, 0):Dot(pos.Unit)))
			local noise = 0
			for i = 0, octaves-1 do
				noise += math.noise(pos.X/(amplitude*persistence^i), pos.Y/(amplitude*persistence^i), pos.Z/(amplitude*persistence^i))
			end

			local offset = math.clamp((noise+1)/2, 0, 1)*scale
			-- lowest = math.min(lowest, offset)
			-- highest = math.max(highest, offset)
			vert:setPosition(vert.position.Unit*(1-offset)*self.radius)
		else
			vert:setPosition(vert.position)
		end
	end
	print(lowest, highest)
end

function solid.new(shape, origin, radius, parent)
	assert(shapes[shape], ("Shape '%s' does not exist."):format(shape))
	local self = setmetatable({}, solid)

	self.maid = maid.new()

	self.origin = origin
	self.radius = radius
	self.parent = parent
	self._parent = Instance.new("Folder")
	self._parent.Name = "Solid"
	self._parent.Parent = self.parent

	self.moved = event.new()
	self.maid:GiveTask(self.moved)

	self.vertices, self.triangles = shapes[shape](self)

	self.maid:GiveTask(
		function()
			for i, vert in pairs(self.vertices) do
				vert:Destroy()
				self.vertices[i] = nil
			end
			for i, tri in pairs(self.triangles) do
				tri:Destroy()
				self.triangles[i] = nil
			end
		end
	)

	return self
end

return solid