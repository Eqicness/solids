-- This module provides special actions as seen in the SPECIAL ACTIONS of the main module.

local actions = {}
actions["brief"] = function(instance, argsFunc)
	return instance:FindFirstChild(argsFunc(), true), true
end
actions["b"] = actions["brief"]

return actions