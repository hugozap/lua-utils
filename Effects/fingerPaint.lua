-- fingerPaint Library for Corona SDK
-- Copyright (c) 2014 Jason Schroeder
-- http://www.jasonschroeder.com
-- http://www.twitter.com/schroederapps

--[[ Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. ]]--

local fingerPaint = {}

------------------------------------------------------------------------------------
-- SET VARIABLES FOR VARIOUS SCREEN POSITIONS
------------------------------------------------------------------------------------
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local screenBottom = display.screenOriginY+display.actualContentHeight
local screenRight = display.screenOriginX+display.actualContentWidth
local screenWidth = screenRight - screenLeft
local screenHeight = screenBottom - screenTop

------------------------------------------------------------------------------------
-- FUNCTION TO CREATE A NEW FINGERPAINT CANVAS
------------------------------------------------------------------------------------
function fingerPaint.newCanvas(width, height, strokeWidth, paintColor, canvasColor)
	
	--------------------------------------------------------------------------------
	-- SET CANVAS WIDTH & HEIGHT (fullscreen if not explicitly defined)
	--------------------------------------------------------------------------------
	if (width == nil or width <= 0) then width = screenWidth end
	if (height == nil or height <= 0) then height = screenHeight end
	
	--------------------------------------------------------------------------------
	-- SET CANVAS BACKGROUND COLOR (white if not explicitly defined)
	--------------------------------------------------------------------------------
	if canvasColor == nil then canvasColor = {1, 1, 1, 1} end
	if canvasColor[4] == nil then canvasColor[4] = 1 end
	local canvasR = canvasColor[1]
	local canvasG = canvasColor[2]
	local canvasB = canvasColor[3]
	local canvasA = canvasColor[4]
	
	--------------------------------------------------------------------------------
	-- SET PAINT COLOR (black if not explicitly defined)
	--------------------------------------------------------------------------------
	if paintColor == nil then paintColor = {0, 0, 0, 1} end
	if paintColor[4] == nil then paintColor[4] = 1 end
	local paintR = paintColor[1]
	local paintG = paintColor[2]
	local paintB = paintColor[3]
	local paintA = paintColor[4]
	
	--------------------------------------------------------------------------------
	-- SET STROKE WIDTH (10 pixels if not explicitly defined)
	--------------------------------------------------------------------------------
	if strokeWidth == nil then strokeWidth = 10 end
	local circleRadius = strokeWidth * .5
	
	--------------------------------------------------------------------------------
	-- CREATE CANVAS CONTAINER OBJECT (centered on screen)
	--------------------------------------------------------------------------------
	local canvas = display.newContainer(width, height)
		canvas.x, canvas.y = centerX, centerY
		canvas.isActive = true
		canvas.paintR, canvas.paintG, canvas.paintB, canvas.paintA = paintR, paintG, paintB, paintA
		canvas.canvasR, canvas.canvasG, canvas.canvasB, canvas.canvasA = canvasR, canvasG, canvasB, canvasA
	
	--------------------------------------------------------------------------------
	-- CREATE CANVAS BACKGROUND RECT
	--------------------------------------------------------------------------------
	local background = display.newRect(canvas, screenLeft - screenWidth, screenTop - screenHeight, screenWidth * 3, screenHeight * 3)
	background:setFillColor(canvasR, canvasG, canvasB)
	background.isHitTestable = true
		
	--------------------------------------------------------------------------------
	-- CREATE TABLE TO HOLD PAINT STROKES
	--------------------------------------------------------------------------------
	canvas.strokes = {}
	local strokes = canvas.strokes
	
	--------------------------------------------------------------------------------
	-- CREATE TABLE TO HOLD UNDONE PAINT STROKES
	--------------------------------------------------------------------------------
	canvas.undone = {}
	local undone = canvas.undone
	
	--------------------------------------------------------------------------------
	-- SET VARIABLE TO TEST IF TOUCHES BEGAN ON CANVAS
	--------------------------------------------------------------------------------
	local touchBegan = false
	
	--------------------------------------------------------------------------------
	-- TOUCH EVENT HANDLER FUNCTION
	--------------------------------------------------------------------------------
	local function touch(event)
		-- set local variables
		local phase = event.phase
		local target = event.target
		local stroke = strokes[#strokes]
		
		-- recalculate touch cooridnates, taking into account canvas position
		local canvasX, canvasY = canvas:localToContent(canvas.anchorX, canvas.anchorY)
		local x = event.x - canvasX
		local y = event.y - canvasY
		local xStart = event.xStart - canvasX
		local yStart = event.yStart - canvasY
		
		-- check for event phase & start, update, or end stroke accordingly
		if phase == "began" and canvas.isActive then
			-- empty undone table
			for i=#undone,1,-1 do
				display.remove(undone[i])
				undone[i] = nil
			end
			-- start stroke
			display.getCurrentStage():setFocus(target)
			touchBegan = true
			strokes[#strokes+1] = display.newGroup()
			stroke = strokes[#strokes]
			canvas:insert(stroke)
			local circle = display.newCircle(stroke, x, y, circleRadius)
				circle:setFillColor(paintR, paintG, paintB, paintA)
		elseif (phase=="moved" and touchBegan == true) then
			-- append to stroke
			if stroke.line == nil then 
				stroke.line = display.newLine(stroke, xStart, yStart, x, y)
			else
				stroke.line:append(x, y)
			end
			stroke.line:setStrokeColor(paintR, paintG, paintB, paintA)
			stroke.line.strokeWidth = strokeWidth
		elseif (phase == "cancelled" or phase == "ended") and touchBegan == true then
			-- end stroke
			display.getCurrentStage():setFocus(nil)
			touchBegan = false
			local circle = display.newCircle(stroke, x, y, circleRadius)
				circle:setFillColor(paintR, paintG, paintB, paintA)
			return true
		end	
	end
	
	--------------------------------------------------------------------------------
	-- ADD TOUCH LISTENER TO CANVAS
	--------------------------------------------------------------------------------
	canvas:addEventListener("touch", touch)
	
	--------------------------------------------------------------------------------
	-- FUNCTION TO CHANGE PAINT COLOR
	--------------------------------------------------------------------------------
	function canvas:setPaintColor(r, g, b, a)
		if a == nil then a = 1 end
		paintR = r
		paintG = g
		paintB = b
		paintA = a
		canvas.paintR, canvas.paintG, canvas.paintB, canvas.paintA = paintR, paintG, paintB, paintA
	end
	
	--------------------------------------------------------------------------------
	-- FUNCTION TO CHANGE CANVAS COLOR
	--------------------------------------------------------------------------------
	function canvas:setCanvasColor(r, g, b, a)
		if a == nil then a = 1 end
		background:setFillColor(r,g,b,a)
		canvasR = r
		canvasG = g
		canvasB = b
		canvasA = a
		canvas.canvasR, canvas.canvasG, canvas.canvasB, canvas.canvasA = canvasR, canvasG, canvasB, canvasA
	end
	
	--------------------------------------------------------------------------------
	-- FUNCTION TO CHANGE STROKE WIDTH
	--------------------------------------------------------------------------------
	function canvas:setStrokeWidth(newWidth)
		strokeWidth = newWidth
		circleRadius = newWidth * .5
	end
	
	--------------------------------------------------------------------------------
	-- FUNCTION TO UNDO PAINT STROKES
	--------------------------------------------------------------------------------
	function canvas:undo()
		if #strokes>0 then
			local n = #strokes
			local stroke = strokes[n]
			table.remove(strokes, n)
			strokes[n] = nil
			undone[#undone+1] = stroke
			stroke.isVisible = false
		end
	end
	
	--------------------------------------------------------------------------------
	-- FUNCTION TO REDO PAINT STROKES
	--------------------------------------------------------------------------------
	function canvas:redo()
		if #undone>0 then
			local n = #undone
			local stroke = undone[n]
			table.remove(undone, n)
			undone[n] = nil
			strokes[#strokes+1] = stroke
			stroke.isVisible = true
		end
	end
	
	return canvas
end

return fingerPaint