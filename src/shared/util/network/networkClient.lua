local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")

local network = {}
local handlers = {}

local function connectHandlerRemote(name)
	local remote = remotesFolder:WaitForChild(name)	-- a promise here might be good
	
	remote.OnClientEvent:Connect(function(...)
		local handler = handlers[name]
		handler(...)
	end)
end

network.handlers = setmetatable({}, {
	__index = function(self, name)
		return handlers[name]
	end,
	__newindex = function(self, name, handler)
		if not handlers[name] then
			-- first time, remote needs to be connected.
			handlers[name] = handler

			connectHandlerRemote(name)
		else
			handlers[name] = handler
		end
	end
})

function network.send(name, ...)
	local remote = remotesFolder:FindFirstChild(name)
	if not remote then
		error("No remote named '" .. name .. "'.")
	end

	if remote:IsA("RemoteEvent") then
		remote:FireServer(...)
	else
		error("Cannot send to function")
	end
end

function network.get(name, ...)
	local remote = remotesFolder:FindFirstChild(name)
	if not remote then
		error("No remote named '" .. name .. "'.")
	end

	if remote:IsA("RemoteFunction") then
		return remote:InvokeServer(...)
	else
		error("Cannot get from event")
	end
end

return network