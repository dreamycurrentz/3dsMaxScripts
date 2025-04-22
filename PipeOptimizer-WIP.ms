global sPipeOptimizerInstance = undefined

struct sPipeOptimizer
(
	_radiusVal = 0,
	
	fn IsValidObject obj =
	(
		return (classOf obj == Editable_Poly)
	),
	
-- 	fn IsValidSplineObj obj = 
-- 	(
-- 		return ((classof currentSplineShapeObj) == SplineShape)
-- 	),
	
	fn CreateKnotFromVertices obj vertexBArr pointPosArr =
	(
		local totalPos = [0,0,0]
		local vertPositionArr = polyop.getVerts obj vertexBArr
		local setRadiusValBool = false
		
		for idx = 1 to vertPositionArr.count do
		(
			totalPos += vertPositionArr[idx]
		)
		
		local avgPos = totalPos / (vertPositionArr.count)
		
		append pointPosArr avgPos
		
		format "pointPosArr: %\n" pointPosArr
		format "avgPos: %\n" avgPos
		
-- 		local pt = Point size: 5 pos: avgPos
		
		distanceVal = distance vertPositionArr[1] avgPos
		format "distanceVal: %\n" distanceVal
		format "radiusVal: %\n" radiusVal
		
		if not setRadiusValBool do 
		(
			this._radiusVal = distanceVal
			setRadiusValBool = true
		)
	
		format "vertPositionArr: %\n" vertPositionArr
		format "radiusVal: %\n" radiusVal
	),
	
	fn ConnectPoints pointPosArr radiusVal =
	(
		local ss = SplineShape pos:[0,0,0]
		addNewSpline ss
			
		if (pointPosArr.count > 1) do
		(
			for i = 1 to pointPosArr.count do
			(
				addKnot ss 1 #corner #line pointPosArr[i]
			)
		)

		ss.render_displayRenderMesh = true
		ss.render_sides = 5
		ss.render_thickness = (this._radiusVal * 2)
		updateShape ss
		return ss
	),
	
	fn AutomaticEdgeSelection obj = 
	(
		local selectedVerticesBArr = polyop.getVertSelection obj
		
		if (selectedVerticesBArr.numberSet > 0 and getSelectionLevel $ == #vertex) then
		(
			local totalVertices = obj.numverts
			local currentVertexSelectionBArr = #{}
			local previousVertexSelectionBArr = #{}
			local pointPosArr = #()
			local counter = 1
			local extraRun = true
			local radiusVal = 0
			
			while ((polyop.getVertSelection obj).numberSet < totalVertices) or (extraRun == true) do
			(
				selectedVerticesBArr = polyop.getVertSelection obj
	
				currentVertexSelectionBArr = selectedVerticesBArr - previousVertexSelectionBArr
				previousVertexSelectionBArr = selectedVerticesBArr
				
				CreateKnotFromVertices obj currentVertexSelectionBArr pointPosArr
				
				if ((polyop.getVertSelection obj).numberSet >= totalVertices) do extraRun = false

				counter += 1
				obj.GrowSelection selLevel: #vertex
			)
			
			format "RadiusValBeforeConnectPoints: %\n" this._radiusVal
			
			
			local currentSplineShapeObj = ConnectPoints pointPosArr this._radiusVal
-- 			format "classof currentSplineShapeObj: %\n" (classof currentSplineShapeObj)
			-- Set cap to false in the spline
			currentSplineShapeObj.cap = false
			
			
			-- Set the sides of the radial to 3. Need to link it to the spinner
			if ((classof currentSplineShapeObj) == SplineShape) then
			(
				currentSplineShapeObj.sides = 3
			)
			else
			(
				messageBox "The selected object is not a spline"
			)
			
		)
		else
		(
			messagebox "Select a vertex loop"
		)
	),
	
	-- This function removes the knots if the knots are of odd number
	fn RemoveAlternateKnotsOdd do
	(
		
	),
	
	-- Deletes every other selected knot from the currently selected spline object
	fn DeleteAlternateKnotsFromSelection =
	(
		-- Get the first selected object
		local splineObj = (selection as array)[1]
		
		-- Ensure a valid spline object is selected
-- 		if (IsValidSplineObj splineObj) do
-- 		(
		-- Get the total number of splines
		local totalSplines = numSplines splineObj
		
		-- Iterate through each spline in the shape
		for splineIdx = 1 to totalSplines do
		(
			-- Array to store knots for deletion
			local knotsToDeleteArr = #()
			
			-- Retreive the selected knots for the current spline
			local selectedKnotsArr = getKnotSelection splineObj splineIdx
			
			-- Store the selected knots if any exist
			if (selectedKnotsArr.count > 0) do
			(
				append knotsToDeleteArr selectedKnotsArr
			)
			
			-- Loop through the stored knots array and delete alternate ones
			for knotGroupIdx = 1 to knotsToDeleteArr.count do
			(
				-- Ensure if the selected knots array has muliptle knots
				if(knotsToDeleteArr[knotGroupIdx].count > 1) do
				(
					-- Check if no of knots are even or odd
					-- If it's even weld inbetweens
					if (mod knotsToDeleteArr[knotGroupIdx].count 2 == 0) then
					(
						format "Even\n" 
						format "selectedKnotsArr: %\n" selectedKnotsArr
						-- Loop through knots (backward) to select the two knots prior to the last one
						-- Delete knots in reverse order to prevent index shifting
						for knotIdx = knotsToDeleteArr[knotGroupIdx].count - 1 to 2 by -2 do
						(
							local currentKnotsGroupArr = knotsToDeleteArr[knotGroupIdx]
							
							format "knotIdx: %\n" knotIdx
							
							local pairedKnotsArr = #()
							append pairedKnotsArr currentKnotsGroupArr[knotIdx]
							append pairedKnotsArr currentKnotsGroupArr[(knotIdx - 1)]
							
-- 							format "tempArr: %\n" tempArr
							-- Select two knots prior to the last one
							setKnotSelection splineObj splineIdx pairedKnotsArr
							
							-- Weld the selected knots
							weldSpline splineObj 100
						)
					)
					-- If it's odd remove alternate knots
					else
					(
						-- Loop through the stored knots and delete alternate ones
						for knotGroupIdx = 1 to knotsToDeleteArr.count do
						(
							-- Ensure if the selected knots array has muliptle knots
							if(knotsToDeleteArr[knotGroupIdx].count > 1) do
							(
								-- Delete knots in reverse order to prevent index shifting
								for knotIdx = knotsToDeleteArr[knotGroupIdx].count - 1 to 1 by -1 do
								(
									-- Delete only alternate knots (even-indexed positions)
									if (mod knotIdx 2 == 0) do
									(
										deleteKnot splineObj splineIdx knotsToDeleteArr[knotGroupIdx][knotIdx]
									)
								)
							)
						)
					)
				)
			)
			-- Update shape to reflect the spline changes on to viewport
			updateShape splineObj
			)
-- 		)
	),
	
	fn TrackEdgeSelection =
	(
		print("Entered\n")
	),
	
	fn ManualEdgeSelection obj =
	(
		-- Ensure no duplicates
		
	),
	
	fn OptimizePipes =
	(
		local obj = (selection as array)[1]
		
		if (IsValidObject obj) do
		(
			-- Two methods
			-- 1. Manual edge selection
			-- 2. Automatic edge selection

			AutomaticEdgeSelection obj
-- 			ManualEdgeSelection obj
			
-- 			AutomaticVertexSelection obj
			
-- 			callbacks.removeScripts id:#edgeSelectionTracker
-- 			callbacks.addScript #selectionSetChanged "TrackEdgeSelection()" id:#edgeSelectionTracker
			
		)
	)
)

sPipeOptimizerInstance = sPipeOptimizer()
sPipeOptimizerInstance.OptimizePipes()
-- sPipeOptimizerInstance.DeleteAlternateKnotsFromSelection()



/*
local cylinderEndsBool = true

-- Loop the selected edges
PolyToolsSelect.Loop cylinderEndsBool

-- Get selected edges
local totalSelectedEdgesBArr = polyop.getEdgeSelection obj
format "Selected edges: %\n" selectedEdgesBArr

local connectedEdgesArr = #()
local visitedEdges = #{}

-- Traverse all the edges and store the connected edges in an array
for edge in totalSelectedEdgesBArr do
(
	if visitedEdges[edge] then continue
		
	polyop.setEdgeSelection obj #{edge}
	PolyToolsSelect.Loop cylinderEndsBool
	local currentSelectedEdgesBArr = polyop.getEdgeSelection obj
	visitedEdges += currentSelectedEdgesBArr
	appendIfUnique connectedEdgesArr currentSelectedEdgesBArr
)
polyop.setEdgeSelection obj totalSelectedEdgesBArr
format "connectedEdgesArr: %\n" connectedEdgesArr

local totalPos = [0,0,0]
local pointPosArr = #()
local radiusVal = 0

-- Get the center of point of the connected edges
for idx = 1 to connectedEdgesArr.count do
(
	totalPos = [0,0,0]
	
	local currentEdgeLoopVertsBArr = polyop.getVertsUsingEdge obj connectedEdgesArr[idx]
	format "currentEdgeLoopVertsBArr: %\n" currentEdgeLoopVertsBArr

	local vertPositionArr = polyop.getVerts obj currentEdgeLoopVertsBArr
	format "vertPositionArr: %\n" vertPositionArr
	
	for idx = 1 to vertPositionArr.count do
	(
		totalPos += vertPositionArr[idx]
	)
	
	local avgPos = totalPos / (vertPositionArr.count)
	
	append pointPosArr avgPos
	format "avgPos: %\n" avgPos
	
	radiusVal = distance vertPositionArr[1] avgPos
	
	format "radiusVal: %\n" radiusVal
-- 				local pt = Point size: 5 pos: avgPos
)


-- Connect the points
local ss = SplineShape pos:[0,0,0]
addNewSpline ss

if (pointPosArr.count > 1) do
(
	for i = 1 to pointPosArr.count do
	(
		addKnot ss 1 #corner #line pointPosArr[i]
	)
)

-- Render in viewport - final tweaks
ss.render_displayRenderMesh = true
ss.render_sides = 5
ss.render_thickness = (radiusVal * 2)
updateShape ss

-- Correct the knot order
*/



-- 		local totalKnots = numKnots splineObj splineIndex
-- 		format "totalKnots: %\n" totalKnots




/*
-- Get the center of point of the connected edges
for idx = 1 to connectedEdgesArr.count do
(
	totalPos = [0,0,0]
	
	local currentEdgeLoopVertsBArr = polyop.getVertsUsingEdge obj connectedEdgesArr[idx]
	format "currentEdgeLoopVertsBArr: %\n" currentEdgeLoopVertsBArr

	local vertPositionArr = polyop.getVerts obj currentEdgeLoopVertsBArr
	format "vertPositionArr: %\n" vertPositionArr
	
	for idx = 1 to vertPositionArr.count do
	(
		totalPos += vertPositionArr[idx]
	)
	
	local avgPos = totalPos / (vertPositionArr.count)
	
	append pointPosArr avgPos
	format "avgPos: %\n" avgPos
	
	radiusVal = distance vertPositionArr[1] avgPos
	
	format "radiusVal: %\n" radiusVal
-- 				local pt = Point size: 5 pos: avgPos
)
*/
