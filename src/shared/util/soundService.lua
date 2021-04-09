local soundService = {}

function soundService.play(sound, part, volume)
	local clone = sound:Clone()

	clone.Parent = part or workspace
	clone.Volume = volume or 1

	clone:Play()
	clone.Ended:Connect(function()
		clone:Destroy()
	end)
	return clone
end

return soundService