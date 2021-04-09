local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = ReplicatedStorage
end

local network = {}
local handlers = {}
local callbacks = {}

local function newHandlerRemote(name)
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.OnServerEvent:Connect(function(...)
		local handler = handlers[name]
		handler(...)
	end)
	remote.Parent = remotesFolder
end

local function newCallbackRemote(name)
	local remote = Instance.new("RemoteFunction")
	remote.Name = name
	remote.OnServerInvoke = function(...)
		local callback = callbacks[name]
		return callback(...)
	end
	remote.Parent = remotesFolder
end

network.callbacks = setmetatable({}, {
	__index = function(self, name)
		return callbacks[name]
	end,
	__newindex = function(self, name, callback)
		if not remotesFolder:FindFirstChild(name) then
			newCallbackRemote(name)
		end
		
		callbacks[name] = callback
	end
})
network.handlers = setmetatable({}, {
	__index = function(self, name)
		return handlers[name]
	end,
	__newindex = function(self, name, handler)
		if not remotesFolder:FindFirstChild(name) then
			newHandlerRemote(name)
		end
		
		handlers[name] = handler
	end
})

function network.send(name, target, ...)
	local remote = remotesFolder:FindFirstChild(name)
	if not remote then
		error("No remote named '" .. name .. "'.")
	end
	
	if target == nil then
		-- all players
		if remote:IsA("RemoteEvent") then
			remote:FireAllClients(...)
		else
			error("Server cannot invoke client.")
		end
	elseif typeof(target) == "table" then
		-- multiple players
		-- target must be an array
		for _, plr in ipairs(target) do
			network.send(name, plr, ...)
		end
	else
		-- single player
		if remote:IsA("RemoteEvent") then
			remote:FireClient(target, ...)
		else
			error("Server cannot invoke client.")
		end
	end
end

return network