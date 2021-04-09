local get = require(game:GetService("ReplicatedStorage").Shared.get)

local maid = get("*s.libs.maid")
local triUtil = get("*s.util.triUtil")
local rightTriangle = get("*a.RightTriangle")

local triangle = {}
triangle.__index = triangle

function triangle:Destroy()
	self.maid:Destroy()
end

function triangle:refresh(fullRefresh)
	if not self._tris or fullRefresh then
		self.maid.triTask = nil

		self._tris = {rightTriangle:Clone(), rightTriangle:Clone()}
		self._tris[1].Name = "TriA"
		self._tris[2].Name = "TriB"
		self.maid.triTask = function()
			for _, tri in pairs(self._tris) do
				tri:Destroy()
			end
			self._tris = nil
		end
	end

	local cfA, sizeA, cfB, sizeB = triUtil.calc3dTriangle2(self.vertices[1]:getWorldPosition(), self.vertices[2]:getWorldPosition(), self.vertices[3]:getWorldPosition(), self.doOffset)
	self._tris[1].CFrame, self._tris[1].Size, self._tris[1].Parent = cfA, sizeA, self._parent
	self._tris[2].CFrame, self._tris[2].Size, self._tris[2].Parent = cfB, sizeB, self._parent
end

function triangle:setParent(newParent)
	self.parent = newParent
	self._parent.Parent = self.parent
	self:refresh()
end

function triangle.new(vA, vB, vC, parent, doOffset)
	local self = setmetatable({}, triangle)

	self.vertices = {vA, vB, vC}
	self.parent = parent
	self.doOffset = doOffset == nil and true or doOffset

	self.maid = maid.new()

	self._parent = Instance.new("Folder")
	self._parent.Name = "Triangle"
	self._parent.Parent = self.parent
	self.maid:GiveTask(self._parent)

	for _, vertex in pairs(self.vertices) do
		self.maid:GiveTask(
			vertex.moved:Connect(
				function()
					self:refresh()
				end
			)
		)
	end

	self:refresh()

	return self
end

return triangle