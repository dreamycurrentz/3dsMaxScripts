-- This script works as a backend code for handling HandyUVToolkit
-- It's designed to identify and resolve UV map overlaps based on two models,
-- 1. Bounding box calculation and
-- 2. Edge based calculation

-- It provides additional features such as Offsetting UVs based on the U and V values provided.

struct OverlappedUV
(
	-- Calculates the area data for each UV shell
	fn GetAreaUVShells unwrapMod uvShells =
	(
		-- Declaring position (x, y), dimensions (width, height), areaUVW and areaGeom
		local x = 0, y = 0, width = 0, height = 0, areaUVW = 0, areaGeom = 0

		-- Collecting minimumMaximumData by processing the uvShells array
		local minMaxDataLocal = for i = 1 to uvShells.count collect
		(
			-- Get the area and bounding box data for the current UV shell
			unwrapMod.getArea uvShells[i] &x &y &width &height &areaUVW &areaGeom
				
			 -- Collect the position (x, y) and dimensions (width, height) of the bounding box
			#(x, y, width, height)
		)
		return minMaxDataLocal
	),
	
	-- Returns UVShell from selectedfaces in an array of bitarrays
	fn GetUVShell unwrapMod selectedFaces numFaces uvShells =
	(
		-- Convert the selectedFaces to array and store it in a variable
		local selectedFacesArray = selectedFaces as Array
		
		-- Loop that runs till selectedFacesArray is 0
		while (selectedFacesArray.count > 0) do
		(
			-- Select the face of the first element in selectedFacesArray
			unwrapMod.selectFaces #{selectedFacesArray[1]}
			
			-- Selects the elements from the faceSelection (from the above step)
			unwrapMod.selectElement()
			
			-- Gets the selected faces
			local selectedElementFaces = unwrapMod.getSelectedFaces()
			
			-- Append the selectedElementFaces to the uvShells array
			append uvShells selectedElementFaces
			
			-- Loop to iterate selectedElementFaces
			for element in selectedElementFaces do
			(
				-- Gets the index of element in selectedFacesArray
				local index = findItem selectedFacesArray element
				
				-- If index is present then delete the item in selectedFacesArray.
				if (index != 0) do
				(
					deleteItem selectedFacesArray index
				)
			)
		)
					
		-- Return UV shells
		return uvShells
		
	),
	
	-- Function to get UVShellData from the selected faces and stores in an array of bitarrays. 
	-- Here's how the return type looks like,
	-- uvShell= #(#{},#{}..)
	fn GetUVShellData unwrapMod =
	(
		-- Get selected faces
		local selectedFaces = unwrapMod.getSelectedFaces()
		
		-- Get total Faces in the object
		local totalFaceCount = unwrapMod.numberPolygons()
		
		-- Variable to store uvShells
		local uvShells = #()
		
		-- If selected Faces is none then select all the faces
		if selectedFaces.isEmpty do selectedFaces = #{1..totalFaceCount}
	
		-- Returns UV shell data
		return (GetUVShell unwrapMod selectedFaces totalFaceCount uvShells)
	),
	
	
	fn enterOverlappedUVShellIdxArray overlappedUVShellIdxArray i j = 
	(
		if (overlappedUVShellIdxArray.count == 0) then
		(
			append overlappedUVShellIdxArray #{i,j}
		)
		else
		(
			local breakLoop = false
			local counter = 1
			
			for data in overlappedUVShellIdxArray where breakLoop == false do
			(
				if (data[i] == 0 and data[j] == 0 and counter >= overlappedUVShellIdxArray.count) then
				(
					append overlappedUVShellIdxArray #{i,j}
					breakLoop = true
				)
				else if (data[i] == 1 and data[j] == 0) then
				(
					data[j] = 1
					breakLoop = true
				)
				else if (data[i] == 0 and data[j] == 1) then
				(
					data[i] = 1
					breakLoop = true
				)
				else if (data[i] == 1 and data[j] == 1) then
				(
					breakLoop = true
				)
				counter += 1
			)
		)
	),
	
	fn CheckBoundsOverlap minMaxData =
	(
		local breakLoop = false
		local counter = 0
		local overlappedUVShellIdxArray =#()
		
		for i = 1 to minMaxData.count do
		(
			local x1 = minMaxData[i][1]
			local y1 = minMaxData[i][2]
			local width1 = minMaxData[i][3]
			local height1 = minMaxData[i][4]
			local right1 = x1 + width1
			local bottom1 = y1 + height1
			
			for j = i + 1 to minMaxData.count do
			(
				local x2 = minMaxData[j][1]
				local y2 = minMaxData[j][2]
				local width2 = minMaxData[j][3]
				local height2 = minMaxData[j][4]
				local right2 = x2 + width2
				local bottom2 = y2 + height2
				
				-- Overlap condition
				if ((right1 > x2) and (x1 < right2) and (bottom1 > y2) and (y1 < bottom2)) do
				(
					overlappedUVShellIdxArray = enterOverlappedUVShellIdxArray overlappedUVShellIdxArray i j
				)
			)
		)
		return overlappedUVShellIdxArray
	),
	
	-- Replaces the indices in overlappedUVShellIdxArray with the actual UV shell data from uvShells
	fn ReplaceIdxArrayWithActualArray uvShells overlappedUVShellIdxArray =
	(
		-- Initialize a new array to store the converted UV shells
		local overlappedUVShellArray = for overlappedUVShellIdx in overlappedUVShellIdxArray collect
		(
			-- Create a new bitarray to combine UV shell data
			local newSet = #{}
			
			-- Iterate through each index in the current bitarray (overlappedUVShellIdx) and add that to newSet
			for idx in overlappedUVShellIdx do newSet += uvShells[idx]
			
			--  -- Return the combined UV shell data for this bitarray
			newSet
		)
		
		-- Return the final array of combined UV shell data
		return overlappedUVShellArray
	),
	
	-- Assign groups for overlapped faces by looping overlappedUVShellArray
	fn AssignSmoothingGroup unwrapMod overlappedUVShellArray =
	(
		-- Choose SubObjectLevel 3
		unwrapMod.setTVSubObjectMode 3
		
		-- Deselect all the faces
		unwrapMod.selectFaces #{}
		
		-- Looping overlappedUVShellArray 
		for i = 1 to overlappedUVShellArray.count do
		(
			-- Store overlappedUVShellArray[i] to tempVariable currFaceSelection
			local currFaceSelection = overlappedUVShellArray[i]
			
			-- Select faces in currFaceSelection
			unwrapMod.selectFaces currFaceSelection
			
			-- Create group for the current selection
			unwrapMod.GroupCreateBySelection()
			
			-- Deselect all the selected faces as it will overlap with the next iteration
			unwrapMod.selectFaces #{}
		)

	),
	
	fn GetUVShellEdgeArray unwrapMod uvShells =
	(
		local uvShellEdgeArray = #()
		for index = 1 to uvShells.count do 
		(
			unwrapMod.selectFaces uvShells[index]
			unwrapMod.faceToEdgeSelect()
			
			local edgeArray = unwrapMod.getSelectedEdges()
			append uvShellEdgeArray edgeArray
		)
		return uvShellEdgeArray
	),
	
	fn GetUVShellEdgeToVertArray unwrapMod =
	(
		local totalPolygons = unwrapMod.numberPolygons()
		unwrapMod.selectFaces #{1..totalPolygons}
		unwrapMod.faceToEdgeSelect()
		
		local totalEdges = unwrapMod.getSelectedEdges()
		local totalEdgesCount = totalEdges.numberSet
		
		local edgeToVertArray = #()
		
		for edgeIndex = 1 to totalEdgesCount do
		(
			unwrapMod.selectEdges #{edgeIndex}
			unwrapMod.edgeToVertSelect()
			local vertArray = (unwrapMod.getSelectedVertices()) as array
			append edgeToVertArray vertArray
		)
		
		return edgeToVertArray
	),
	
	fn GetVertToVertArray unwrapMod = 
	(
		local totalVertices = unwrapMod.NumberVertices()
		local vertToVertPositionArray = for i = 1 to totalVertices collect (unwrapMod.getVertexPosition 0 i)
		return vertToVertPositionArray
	),
	
	fn checkIntersection currEdge nextEdge edgeToVertArray vertToVertPositionArray =
	(
		
		-- Cache vertex positions for the current edge
		local currEdgeVerts = edgeToVertArray[currEdge]
		local nextEdgeVerts = edgeToVertArray[nextEdge]

		-- Extract x, y coordinates
		x1 = vertToVertPositionArray[currEdgeVerts[1]].x
		y1 = vertToVertPositionArray[currEdgeVerts[1]].y
		x2 = vertToVertPositionArray[currEdgeVerts[2]].x
		y2 = vertToVertPositionArray[currEdgeVerts[2]].y
		
		x3 = vertToVertPositionArray[nextEdgeVerts[1]].x
		y3 = vertToVertPositionArray[nextEdgeVerts[1]].y
		x4 = vertToVertPositionArray[nextEdgeVerts[2]].x
		y4 = vertToVertPositionArray[nextEdgeVerts[2]].y
		
		-- Prefetch calculations
		diff1 = y1 - y3
		diff2 = x1 - x3
		diff3 = x1 - x2
		diff4 = y3 - y4
		diff5 = y1 - y2
		diff6 = x3 - x4
		
		-- Compute denominator
		denom = (diff3) * (diff4) - (diff5) * (diff6)
		
		-- Calculate t and u
		t = (((diff2)*(diff4)) - ((diff1)*(diff6))) / denom
		u = -(((diff3)*(diff1)) - ((diff5)*(diff2))) / denom
		
		-- Intersection condition	
		if ((0 <= t and t <= 1) and (0 <= u and u <= 1)) then
		(
			return true
		)
		else
		(
			return false
		)
	),
	
	fn traverseEdgeElement currElementEdges nextElementEdges edgeToVertArray vertToVertPositionArray = 
	(
		for currEdge in currElementEdges do
		(
			for nextEdge in nextElementEdges do
			(
				if (checkIntersection currEdge nextEdge edgeToVertArray vertToVertPositionArray) then
				(
					return true
				)
			)
		)
		return false
	),
	
	fn CheckEdgesOverlap uvShellEdgeArray edgeToVertArray vertToVertPositionArray = 
	(
		local overlappedUVShellIdxArray = #()
		
		for i = 1 to uvShellEdgeArray.count do
		(
			for j = i + 1 to uvShellEdgeArray.count where i != j do
			(
				local doesEdgesIntersectBool = traverseEdgeElement uvShellEdgeArray[i] uvShellEdgeArray[j] edgeToVertArray vertToVertPositionArray
				
				-- Overlap condition
				if (doesEdgesIntersectBool) do
				(
					overlappedUVShellIdxArray = enterOverlappedUVShellIdxArray overlappedUVShellIdxArray i j
				)
			)
		)
		return overlappedUVShellIdxArray
	),
	
	-- Function to check UV overlap using the specified method
	-- Parameters:
	-- method: 1 for Bounding Box method, 2 for Edge-based method
	-- selectedObjects: Array of selected objects
	fn CheckUVOverlap selectedObjects method =
	(
		local start = timestamp()
		
		if (selectedObjects.count == 1) do
		(
			local obj = selectedObjects[1]
			
			if(((classOf obj.baseObject) == Editable_Poly) and ((classOf obj.modifiers[obj.modifiers.count]) == Unwrap_UVW)) do
			(
				local unwrapMod = obj.modifiers[obj.modifiers.count]
				if(unwrapMod != undefined) do
				(
					with undo off, redraw off
					(
						local uvShells = GetUVShellData unwrapMod
						format "UVShell: %\n" uvShells
						/*
						if(uvShells.count > 0) do
						(
							-- Bouding box method
							if (method == 1) then
							(
								local minMaxData = GetAreaUVShells unwrapMod uvShells
								local overlappedUVShellIdxArray = CheckBoundsOverlap minMaxData
								local overlappedUVShellArray = ReplaceIdxArrayWithActualArray uvShells overlappedUVShellIdxArray
								AssignSmoothingGroup unwrapMod overlappedUVShellArray
								format "Bouding box calculation done.\n"
							)
							-- Edge-based method
							else if (method == 2) then
							(
								local uvShellEdgeArray = GetUVShellEdgeArray unwrapMod uvShells
								local edgeToVertArray = GetUVShellEdgeToVertArray unwrapMod
								local vertToVertPositionArray = GetVertToVertArray unwrapMod
								local overlappedUVShellIdxArray = CheckEdgesOverlap uvShellEdgeArray edgeToVertArray vertToVertPositionArray
								local overlappedUVShellArray = ReplaceIdxArrayWithActualArray uvShells overlappedUVShellIdxArray
								AssignSmoothingGroup unwrapMod overlappedUVShellArray
								format "Edge method calculation done.\n"
							)
							else
							(
								print "Error with the states\n"
							)
						)*/
					)
					
				)
			)
		)
		
		local end = timeStamp()
		format "\nProcessing took % seconds\n" ((end - start) / 1000.0)
	),
	
	-- Function to offset UV coordinates in the Unwrap_UVW modifier
	fn offsetUV offsetVal =
	(
		-- Check if the currently selected modifier in the ModPanel is an Unwrap_UVW modifier
		if (classOf (modPanel.getCurrentObject()) == Unwrap_UVW) then
		(
			-- Get the currently active modifier which is Unwrap_UVW
			local unwrapMod = modPanel.getCurrentObject()
			
			-- Offset the selected UV elements by the given value (offsetVal)
			unwrapMod.moveSelected offsetVal
		)
		else
		(
			-- If no Unwrap_UVW modifier is present, show the message
			messageBox "Add UnwrapUVW modifier"
		)
	)
)

overlappedUVInstance = OverlappedUV()
selectedObjects = (selection as array)
overlappedUVInstance.CheckUVOverlap selectedObjects 1
-- overlappedUVInstance.CheckUVOverlapBoundingMethod selectedObjects


-- Variable to store all the faces in a bitarray
-- selectedFacesBitArray = #{}
-- unwrapMod.selectFaces selectedFacesBitArray
-- Loop through the uvShells array and add the bitarray to selectedFacesBitArray 
-- for element in uvShells do join selectedFacesBitArray element

-- Select the faces in selectedFacesBitArray
-- unwrapMod.selectFaces selectedFacesBitArray


-- 				unwrapMod.setTVSubObjectMode 2
-- 				unwrapMod.selectEdges #{23}
				
-- 				unwrapMod.setTVSubObjectMode 1
-- 				unwrapMod.selectVertices #{2,15}
