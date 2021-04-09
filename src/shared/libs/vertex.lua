local get = require(game:GetService("ReplicatedStorage").Shared.get)

local maid = get("*s.libs.maid")
local event = get("*s.libs.event")

local vertex = {}
vertex.__index = vertex

function vertex:Destroy()
	self.maid:Destroy()
end

function vertex:getWorldPosition()
	return self.solid.origin + self.position
end

function vertex:setPosition(v3)
	self.position = v3

	if self.maid.part then
		self.maid.part.CFrame = CFrame.new(self:getWorldPosition())
	end

	self.moved:Fire()
end

function vertex:show()
	local part = Instance.new("Part")
	part.Size = Vector3.new(1, 1, 1)
	part.Anchored = true
	part.CanCollide = false
	part.Shape = Enum.PartType.Ball
	part.Color = Color3.new(1,.2,.2)
	part.CFrame = CFrame.new(self:getWorldPosition())
	-- can't believe we still have to set surface types.
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = self.solid._parent

	self.maid.part = part
end

function vertex:hide()
	self.maid.part = nil
end

function vertex.new(solid, x, y, z)
	local self = setmetatable({}, vertex)

	self.solid = solid
	self.position = typeof(x) == "Vector3" and x or Vector3.new(x, y, z)

	self.maid = maid.new()

	self.moved = event.new()
	self.maid:GiveTask(self.moved)

	self.maid:GiveTask(
		solid.moved:Connect(
			function()
				self.moved:Fire()
			end
		)
	)

	return self
end

return vertex