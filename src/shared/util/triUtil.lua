local triUtil = {}

-- optimized version of above function
function triUtil.calc3dTriangle(a, b, c)
	local ab, ac, bc = b - a, c - a, c - b	-- defining the triangle segments
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)	-- the dot product of a vector and itself is the square of its magnitude, quick way to calculate magnitude
	
	-- switch vertices so that the edge split is the longest and referred to as bc
	if abd > acd and abd > bcd then
		-- ab is longest
		c, a = a, c
	elseif acd > bcd and acd > abd then
		-- ac is longest
		a, b = b, a
	end
	
	-- reassign so segments are correct
	ab, ac, bc = b - a, c - a, c - b
	
	local right = bc.Unit
	local up = ac:Cross(ab).Unit
	local back = bc:Cross(up).Unit	-- switch and make negative
	
	local height = math.abs(ab:Dot(back))

	-- position triangles
	local ySize = 0.05	--0
	local cfA = CFrame.fromMatrix((a + b)/2, right, -up, -back) * CFrame.new(0, ySize/2, 0)
	local cfB = CFrame.fromMatrix((a + c)/2, -right, up, -back) * CFrame.new(0, ySize/2, 0)
	local sizeA = Vector3.new(math.abs(ab:Dot(right)), ySize, height)
	local sizeB = Vector3.new(math.abs(ac:Dot(right)), ySize, height)
	
	return
		cfA,
		sizeA,
		cfB,
		sizeB
end

return triUtil
