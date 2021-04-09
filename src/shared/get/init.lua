-- Eqicness
-- A module which provides a clean way to access modules and navigate code.
-- Created: 7 December 2020
-- Last updated: 7 December 2020

--[[
	CORE DIRECTORIES
	*[key].[...]								-> refers to the core directory of [key]

	LIST OF CORE DIRECTORIES:
		"": main directory (parent folder)
			> example path(s):
				"*.anInstance.aChild"
		
		"shared": shared directory (ReplicatedStorage.Shared)
			> alias(es):
				"s",
			> example path(s):
				"*shared.anInstance.aChild",
				"*s.anInstance.aChild"

	SPECIAL ACTIONS
	[...]._[action].[arg 1].[arg 2].[...].[arg n]		->	special action. action is proceeded by _ to establish it is an action
	
	LIST OF ACTIONS:
		"brief": allows for a brief path which searches recursively for the first descendant of [name]
			> arguments:
				1: name of instance to search for
			> alias(es):
				"b",
			> example path(s):
				"*._brief.instanceName",
				"*.folderName._b.instanceName"
	
	COMPLETE EXAMPLE PATHS:
		"*.aFolder.aModule"				-> returns the required module named "aModule" parented to
										   the folder named "aFolder" which is a child of the main
										   core directory.
		"*s.otherFolder.otherModule"	-> returns the required module named "otherModule" parented
										   to the folder named "otherFolder" which is a child of
										   the shared core directory.
		"*s._b.someModule"				-> returns the required module named "someModule" which is
										   a descendant of the shared core directory.
]]

local coreDirs = require(script.coreDirectories)
local actions = require(script.actions)

local function process(instance)
	if instance:IsA("ModuleScript") then
		return require(instance)
	end

	return instance
end

return function(path)
	local pathMatch = string.gmatch(path, "[_%*%w]+")
	local instance

	local next = pathMatch()
	while next ~= nil do
		if next:sub(1,1) == "*" then	-- core directory
			local key = next:sub(2)
			instance = coreDirs[key]

			if not instance then
				error(string.format("Core Directory \"%s\" for path \"%s\" not found.", key, path))
			end
		elseif next:sub(1,1) == "_" then	-- special action
			local key = next:sub(2)
			local action = actions[key]
			if action then
				local result, isFinal = action(instance, pathMatch)
				instance = result
				
				if isFinal then
					break
				end
			else
				error(string.format("Action \"%s\" for path \"%s\" not found.", key, path))
			end
		else	-- specific search
			instance = instance:FindFirstChild(next)
		end
		
		if not instance then
			error(string.format("Instance \"%s\" for path \"%s\" not found.", next, path))
		end

		next = pathMatch()
	end

	return process(instance)
end