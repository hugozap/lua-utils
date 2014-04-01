local Polyk = require("Polyk")
-- Busted tests

describe("Polyk tests",function ()
	describe("Simple polygon validations",function()

		it("Triangle Should be simple polygon",function()
			local p={}
			p[1] = 0
			p[2] = 0
			p[3] = 1
			p[4] = 1
			p[5] = 2
			p[6] = 0
			assert.True(Polyk.IsSimple(p))
		end)


		it("Complex polygon should be not simple", function()
			local p={}
			p[1] = 0
			p[2] = 0
			p[3] = 1
			p[4] = 1
			p[5] = 2
			p[6] = 0
			p[7] = 0
			p[8] = 7
			p[9] = 0
			p[10] = 0
			assert.False(Polyk.IsSimple(p))
		end)
	end)

	describe("Contains point",function()
		local p={}
			p[1] = 0
			p[2] = 0
			p[3] = 1
			p[4] = 1
			p[5] = 2
			p[6] = 0

		it("Should contain point on edge",function()
			assert.True(Polyk.ContainsPoint(p,1,1))
		end)

		it("Should contain point",function()
			assert.True(Polyk.ContainsPoint(p,1.5,0.5))
		end)

		it("Should NOT contain point",function()
			assert.False(Polyk.ContainsPoint(p,4,4))
		end)
	end)
end)

