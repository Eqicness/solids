local get = require(game:GetService("ReplicatedStorage").Shared.get)

return function()
	-- Load stuff

	local triManager = get("*.managers.triManager")
	triManager.init()

	print("Loaded server.")
end