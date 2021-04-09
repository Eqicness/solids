local get = require(game:GetService("ReplicatedStorage").Shared.get)

local network = get("*s.util.network")

local replicator = {}
replicator.__index = replicator

function replicator.new(callbacks)
	local self = setmetatable({}, replicator)

	for _, module in pairs(callbacks:GetChildren()) do
		local init = require(module)
		local type, func = init()
		network[type][module.Name] = func
	end
	
	return self
end

return replicator