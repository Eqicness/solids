-- This module provides core directories as seen in the CORE DIRECTORIES section in the main module.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local coreDirs = {}
coreDirs["shared"] = script.Parent.Parent
coreDirs["s"] = coreDirs["shared"]
coreDirs["assets"] = ReplicatedStorage:WaitForChild("Assets")
coreDirs["a"] = coreDirs["assets"]

if RunService:IsServer() then
	coreDirs[""] = game:GetService("ServerStorage"):WaitForChild("Server")	-- "" is the main *. directory
else
	coreDirs[""] = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts"):WaitForChild("Client")
end

return coreDirs