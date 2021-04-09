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

function solid:subdivideTriangle(tri)
	local newVertices = {}
	newVertices[1] = vertex.new(self, (tri.vertices[1].position+tri.vertices[2].position)/2)
	newVertices[2] = vertex.new(self, (tri.vertices[2].position+tri.vertices[3].position)/2)
	newVertices[3] = vertex.new(self, (tri.vertices[1].position+tri.vertices[3].position)/2)

	-- project vertices onto sphere
	-- this slightly distorts triangles, losing equilateralism (is that even a word)
	for _, vert in pairs(newVertices) do
		vert:setPosition(vert.position.Unit * self.radius)
	end

	return newVertices, {
		triangle.new(newVertices[1], newVertices[2], newVertices[3], self._parent),		-- middle
		triangle.new(tri.vertices[1], newVertices[1], newVertices[3], self._parent),	-- top
		triangle.new(tri.vertices[2], newVertices[1], newVertices[2], self._parent),	-- bottom left
		triangle.new(tri.vertices[3], newVertices[2], newVertices[3], self._parent),	-- bottom right
	}
end

function solid:subdivide(levels)
	if levels and levels > 1 then
		for _ = 1, levels do
			self:subdivide()
		end
	else
		print('subdiving once')
		local allNewTris = {}
		for i, oldTri in pairs(self.triangles) do
			local newVerts, newTris = self:subdivideTriangle(oldTri)
			for _, vert in pairs(newVerts) do
				table.insert(self.vertices, vert)
			end
			for _, tri in pairs(newTris) do
				table.insert(allNewTris, tri)
			end
			oldTri:Destroy()
			self.triangles[i] = nil
		end
		self.triangles = allNewTris
	end
end

function solid:setOrigin(v3)
	self.origin = v3
	self.moved:Fire()
end

function solid:randomize(amount)
	local max = 10000 + amount * 10000
	for _, vert in pairs(self.vertices) do
		vert:setPosition(vert.position.Unit*(math.random(10000, max)/10000)*self.radius)
	end
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