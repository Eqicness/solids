local triUtil = {}

function triUtil.calc3dTriangle(a, b, c)
	-- define three possible cases
	local edges = {
		{longest = (c - a), other = (b - a), origin = a},
		{longest = (a - b), other = (c - b), origin = b},
		{longest = (b - c), other = (a - c), origin = c}
	}
	-- other = HYP
	-- longest = ADJ
	-- unknown = OPP

	-- find the one with the longest edge
	local edge = edges[1]
	for i = 2, #edges do
		if edges[i].longest.Magnitude > edge.longest.Magnitude then
			edge = edges[i]
		end
	end

	-- calculate the lengths to determine point D
	-- (splitting up the longest side to create two right triangles)
	local cosine = edge.longest.Unit:Dot(edge.other.Unit)	-- dot returns the cosine of the angle between the two vectors
	local l1 = cosine * edge.other.Magnitude	-- ADJ = HYP * cos(theta)
	local l2 = edge.longest.Magnitude - l1	-- other segment
	local theta = math.acos(cosine)	-- convert the cosine to a radian
	local h = math.sin(theta) * edge.other.Magnitude

	--CFRAME Matrix:
	-- r0 = x, r1 = y, r2 = z
	-- r_0 = RIGHT, r_1 = UP, r_2 = BACK
	-- MATRIX: x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22

	local p1 = edge.origin + 0.5 * edge.other	-- position of first triangle (midpoint of HYP)
	local p2 = edge.origin + edge.longest + 0.5 * (edge.other-edge.longest)	-- position of second triangle (midpoint of OPP)

	-- the directions using the custom meshpart right triangle
	-- hmm... how do we know these are facing the right way?
	local right = edge.longest.Unit	-- this is definitely facing the right way.
	local up = edge.longest:Cross(edge.other).Unit	-- this is right, but idk how to make sure it's right
	local back = -up:Cross(edge.longest).Unit	-- this has to be flipped to be correct
	-- facing the right way is relative. the below works after experimentation, i guess that's how it is
	
	-- normal orientation
	local cfA = CFrame.fromMatrix(p1, right, up, back)

	-- flipped right (and subsequently flipped up)
	local cfB = CFrame.fromMatrix(p2, -right, -up, back)

	return
		cfA,
		Vector3.new(l1, 0.1, h),
		cfB,
		Vector3.new(l2, 0.1, h)
end

-- optimized version of above function
function triUtil.calc3dTriangle2(a, b, c)
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
