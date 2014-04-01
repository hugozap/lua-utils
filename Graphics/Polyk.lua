-- PolyK library ported to LUA,
-- Ported by Hugo Zapata
-- original code by Ivan Kuckir

-- 		Copyright (c) 2012 Ivan Kuckir

-- 		Permission is hereby granted, free of charge, to any person
-- 		obtaining a copy of this software and associated documentation
-- 		files (the "Software"), to deal in the Software without
-- 		restriction, including without limitation the rights to use,
-- 		copy, modify, merge, publish, distribute, sublicense, and/or sell
-- 		copies of the Software, and to permit persons to whom the
-- 		Software is furnished to do so, subject to the following
-- 		conditions:

-- 		The above copyright notice and this permission notice shall be
-- 		included in all copies or substantial portions of the Software.

-- 		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- 		EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- 		OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- 		NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- 		HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- 		WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- 		FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- 		OTHER DEALINGS IN THE SOFTWARE.


local PolyK = {}

function PolyK.InRect(a,b,c)
	if(b.x == c.x) then
		return (a.y >= math.min(b.y,c.y) and a.y <= math.max(b.y,c.y))
	end

	if(b.y == c.y) then
		return (a.x >= math.min(b.x,c.x) and a.x <= math.max(b.x, c.x))
	end

	if(a.x >= math.min(b.x, c.x) and a.x <= math.max(b.x,c.x) and a.y >= math.min(b.y,c.y) and a.y <= math.max(b.y,c.y)) then
		return true
	else
		return false
	end

end

function PolyK.GetLineIntersection(a1,a2,b1,b2,c)
	local dax,dbx = (a1.x - a2.x), (b1.x - b2.x)
	local day,dby = (a1.y - a2.y), (b1.y - b2.y)
	local Den = dax * dby - day * dbx
	if(Den == 0) then
		return null
	end

	local A = (a1.x * a2.y - a1.y * a2.x)
	local B = (b1.x * b2.y - b1.y * b2.x)

	local I = c
	I.x = (A*dbx - dax*B) / Den 
	I.y = (A*dby - day*B) / Den 

	if( PolyK.InRect(I,a1,a2) and PolyK.InRect(I,b1,b2)) then
		return I
	end

	return null

end

-- Is Polygon self-intersecting?
function PolyK.IsSimple(p)
	
	local n = #p / 2
	if n < 4 then 
		return true
	end

	local a1,a2,b1,b2 = {},{},{},{}
	local c = {}

	for i=0,n-1 do
		a1.x = p[2*i+1]
		a1.y = p[2*i+2];
		if i == n-1 then
			a2.x = p[1]
			a2.y = p[2]
		else
			a2.x = p[2*i+3]
			a2.y = p[2*i+4]
		end

		for j=0,n-1 do
			local skip = false
			if (math.abs(i-j)< 2 ) or (j==n-1 and i==0) or (i == n-1 and j==0) then
				skip = true
			end

			if skip == false then
				b1.x = p[2*j+1]
				b1.y = p[2*j+2]

				if (j == n-1) then
					b2.x = p[1]
					b2.y = p[2]
				else
					b2.x = p[2*j+3]
					b2.y = p[2*j+4]
				end

				if(PolyK.GetLineIntersection(a1,a2,b1,b2,c) ~= nil ) then
					return false
				end

			end
		end
	end
end

function PolyK.ContainsPoint(p,px,py)
	
	local n = #p / 2
	local ax
	local ay = p[2*n-2]-py
	local bx = p[2*n-1]-px
	local by = p[2*n]-py
	local lup

	for i=0,n-1 do
		local skip = false
		ax = bx
		ay = by
		bx = p[2*i+1] - px
		by = p[2*i+2] - py
		if(ay == by) then
			skip = true
		else
			lup = by>ay
		end
	end

	local depth = 0
	for i=1,n-1 do
		local skip = false
		ax,ay = bx,by
		bx = p[2*i+1] - px
		by = p[2*i+2] - py

		if(ay<0 and by < 0) or (ay>0 and by>0) or (ax < 0 and bx < 0) then
			skip = true
		end

		if skip == false then
			if(ay == by and math.min(ax,bx)<=0) then
				return true
			end
			if(ay ~= by) then
				local lx = ax + (bx-ax) * (-ay)/(by-ay)
				if(lx == 0) then
					return true  -- point on edge
				end
				if(lx > 0) then
					depth = depth + 1
				end

				if(ay == 0 and lup and by > ay) then
					depth = depth -1 -- hit vertex both up
				end
				if(ay == 0  and lup == false and by < ay) then
					depth = depth - 1 -- hit vertex both down
				end
				lup = by > ay
			end

		end
	end

	return (depth % 2) == 1
end

return PolyK