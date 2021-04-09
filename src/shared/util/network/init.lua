-- File Name: network
-- Author: Eqicness
-- Created: 27 January 2021
-- Modified: 28 January 2021
-- Description: Module to handle communcation between server & client.
--[[
USAGE:

> Defines a new handler (remote event) that recieves information:
	network.handlers["Name"] = function(...)

	end

> Defines a new callback (remote function) that recieves & returns information:
> SERVER ONLY
	network.callbacks["Name"] = function(...)
		return ...
	end

> Sends information to the server (calls a handler)
	network.send("Name", ...)

> Gets information from the server (calls a callback)
> CLIENT ONLY
	local ... = network.get("Name", ...)

]]

local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script.networkServer)
else
	return require(script.networkClient)
end