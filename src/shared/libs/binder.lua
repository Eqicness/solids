-- eqicness
-- 30/01/2021

local CollectionSerivce  = game:GetService("CollectionService")

local get = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("get"))

local maid = get("*s.libs.maid")
local event = get("*s.libs.event")

local binder = {}
binder.__index = binder

function binder:instanceRemoved(instance)
	if self.objects[instance] then
		self.objects[instance]:Destroy()
		self.objects[instance] = nil
		
		self.objectRemoved:Fire(instance)
	end
end

function binder:getObjects()
	return self.objects
end

function binder:instanceAdded(instance)
	if self.objects[instance] then
		self:instanceRemoved(instance)
	end
	
	self.objects[instance] = self.constructor(instance)
	self.objectAdded:Fire(instance)
end

function binder:Destroy()
	for instance in pairs(self.objects) do
		self:instanceRemoved(instance)
	end
	
	self.maid:Destroy()
	self.maid = nil
end

function binder.new(tagName, constructor)
	local self = setmetatable({}, binder)
	
	self.tagName = tagName
	self.constructor = constructor
	self.objects = {}
	self.maid = maid.new()
	
	self.objectAdded = event.new()
	self.objectRemoved = event.new()
	
	self.maid:GiveTask(
		CollectionSerivce:GetInstanceAddedSignal(tagName):Connect(function(...)
			self:instanceAdded(...)
		end)
	)
	
	self.maid:GiveTask(
		CollectionSerivce:GetInstanceRemovedSignal(tagName):Connect(function(...)
			self:instanceRemoved(...)
		end)
	)
	
	for _, instance in pairs(CollectionSerivce:GetTagged(self.tagName)) do
		self:instanceAdded(instance)
	end
	
	return self
end

return binder