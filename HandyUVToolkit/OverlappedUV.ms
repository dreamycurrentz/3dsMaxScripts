-- This script works as a backend code for handling HandyUVToolkit
-- It's designed to identify and resolve UV map overlaps based on two models,
-- 1. Bounding box calculation and
-- 2. Edge based calculation

-- It provides additional features such as Offsetting UVs based on the provided U and V values.

struct OverlappedUV
(
	-- Calculates the area data for each UV shell
	fn calculateUVShellAreaData unwrapModifier uvShellArray =
	(
		-- Declaring position (x, y), dimensions (width, height), areaUVW and areaGeom
		local xPosition = 0, yPosition = 0, uvShellWidth = 0, uvShellHeight = 0, areaUVW = 0, areaGeometry = 0

		-- Collecting minimumMaximumData by processing the uvShells array
		local boundingBoxData = for uvShellIdx = 1 to uvShellArray.count collect
		(
			-- Get the area and bounding box data for the current UV shell
			unwrapModifier.getArea uvShellArray[uvShellIdx] &xPosition &yPosition &uvShellWidth &uvShellHeight &areaUVW &areaGeometry
			
			 -- Collect the position (x, y) and dimensions (width, height) of the bounding box
			#(xPosition, yPosition, uvShellWidth, uvShellHeight)
		)
		return boundingBoxData
	),
	
	-- Function to get UVShell from the selected faces and returns an array of bitarrays.
	-- Here's how the return type looks like,
	-- uvShell= #(#{},#{}..)
	fn GetUVShellsFromSelectedFaces unwrapModifier =
	(
		-- Get selected faces
		local selectedFacesBArr = unwrapModifier.getSelectedFaces()
		
		-- Get total Faces in the object
		local totalFaceCount = unwrapModifier.numberPolygons()
		
		-- Variable to store uvShells
		local uvShellsArr = #()
		
		-- If selected Faces is none then select all the faces
		if selectedFacesBArr.isEmpty do selectedFacesBArr = #{1..totalFaceCount}
			
		-- Convert the selectedFaces to array and store it in a variable
		local selectedFacesArr = selectedFacesBArr as Array
		
		-- Loop that runs till selectedFacesArray is 0
		while (selectedFacesArr.count > 0) do
		(
			-- Select the face of the first element in selectedFacesArray
			unwrapModifier.selectFaces #{selectedFacesArr[1]}
			
			-- Selects the elements from the faceSelection (from the above step)
			unwrapModifier.selectElement()
			
			-- Gets the selected faces
			local currentShellFacesBArr = unwrapModifier.getSelectedFaces()
			
			-- Append the selectedElementFaces to the uvShells array
			append uvShellsArr currentShellFacesBArr
			
			-- Loop to iterate selectedElementFaces
			for faceIdx in currentShellFacesBArr do
			(
				-- Gets the index of element in selectedFacesArray
				local selectedIdx = findItem selectedFacesArr faceIdx
				
				-- If index is present then delete the item in selectedFacesArray.
				if (selectedIdx != 0) do
				(
					deleteItem selectedFacesArr selectedIdx
				)
			)
		)
					
		-- Return UV shells array
		return uvShellsArr
	),
	
	-- Adds or udpates UV Shell index pairs in overlappedUVShellIdxArray containing indices i and j
	fn enterOverlappedUVShellIdxArray overlappedUVShellIdxArray i j = 
	(
		-- If the overlappedUVShellIdxArray is empty then we are directly adding to the array
		if (overlappedUVShellIdxArray.count == 0) then
		(
			append overlappedUVShellIdxArray #{i,j}
		)
		else
		(
			-- Variable to break out of the loop when a condition is satisfied
			local breakLoop = false
			
			-- Counter to track iterations
			local counter = 1
			
			-- Iterate through each bitarray(data) in overlappedUVShellIdxArray while breakLoop is false
			for data in overlappedUVShellIdxArray where breakLoop == false do
			(
				-- Case 1: Both indices i and j are not present in the current bitarray, and we have checked all bitarrays
				if (data[i] == 0 and data[j] == 0 and counter >= overlappedUVShellIdxArray.count) then
				(
					-- Add a new bitarray containing indices i and j to overlappedUVShellIdxArray
					append overlappedUVShellIdxArray #{i,j}
					
					-- Break the loop
					breakLoop = true
				)
				-- Case 2: Index i is present but j is not
				else if (data[i] == 1 and data[j] == 0) then
				(
					-- Add index j to the current bitarray
					data[j] = 1
					
					-- Break the loop
					breakLoop = true
				)
				-- Case 3: Index j is present but i is not
				else if (data[i] == 0 and data[j] == 1) then
				(
					-- Add index i to the current bitarray
					data[i] = 1
					-- Break the loop
					breakLoop = true
				)
				-- Case 4: Both indices i and j are already present in the current bitarray
				else if (data[i] == 1 and data[j] == 1) then
				(
					-- Simply break the loop as no changes are needed
					breakLoop = true
				)
				-- Increment the counter after processing the current bitarray
				counter += 1
			)
		)
		-- Return the updated overlappedUVShellIdxArray
		return overlappedUVShellIdxArray
	),
	
	-- Function to check if UV bounds overlap and return an array of overlapping UV shell index pairs
	fn CheckBoundsOverlap minMaxData =
	(
		-- Initialize an empty array to store overlapping UV shell index pairs
		local overlappedUVShellIdxArray =#()
		
		-- Outer loop to iterate each item in minMaxData
		for i = 1 to minMaxData.count do
		(
			-- Extract the bounding box properties of the current item
			local x1 = minMaxData[i][1]				-- Minimum X-coordinate position
			local y1 = minMaxData[i][2]				-- Minimum Y-coordinate position
			local width1 = minMaxData[i][3]			-- Width of the bounding box
			local height1 = minMaxData[i][4]		-- Height of the boudning box
			local right1 = x1 + width1				-- Maximum X-coordinate position
			local top1 = y1 + height1				-- Maximum Y-coordinate position
			
			-- Inner loop to compare the current item with all subsequent items
			for j = i + 1 to minMaxData.count do
			(
				-- Extract the bounding box properties for the comparison item
				local x2 = minMaxData[j][1]			-- Minimum X-coordinate position
				local y2 = minMaxData[j][2]			-- Minimum Y-coordinate position
				local width2 = minMaxData[j][3]		-- Width of the bounding box
				local height2 = minMaxData[j][4]	-- Height of the boudning box
				local right2 = x2 + width2			-- Maximum X-coordinate position
				local top2 = y2 + height2			-- Maximum Y-coordinate position
				
				-- Check if the two bounding boxes overlap
				if ((right1 > x2) and (x1 < right2) and (top1 > y2) and (y1 < top2)) do
				(
					-- If overlap is detected, add the indices i and j to overlappedUVShellIdxArray
					overlappedUVShellIdxArray = enterOverlappedUVShellIdxArray overlappedUVShellIdxArray i j
				)
			)
		)
		-- Return the array of overlapping UV shell index pairs
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
			
			-- Return the combined UV shell data for this bitarray
			newSet
		)
		
		-- Return the final array of combined UV shell data
		return overlappedUVShellArray
	),
	
	-- Assign groups for overlapped faces by looping overlappedUVShellArray
	fn GroupOverlappedUVShells unwrapModifier overlappedUVShellArray =
	(
		-- Choose SubObjectLevel 3
		unwrapModifier.setTVSubObjectMode 3
		
		-- Deselect all the faces
		unwrapModifier.selectFaces #{}
		
		-- Looping overlappedUVShellArray 
		for i = 1 to overlappedUVShellArray.count do
		(
			-- Store overlappedUVShellArray[i] to tempVariable currentUVShell
			local currentUVShell = overlappedUVShellArray[i]
			
			-- Select faces in currentUVShell
			unwrapModifier.selectFaces currentUVShell
			
			-- Create group for the current selection
			unwrapModifier.GroupCreateBySelection()
			
			-- Deselect all the selected faces as it will overlap with the next iteration
			unwrapModifier.selectFaces #{}
		)
	),
	
	-- Function to generate an array of edge selections for each UV shell
	fn GetUVShellEdgeArray unwrapModifier uvShells =
	(
		-- Initialize an empty array to store edges based on each UV Shell
		local uvShellEdgeArray = #()
		
		--Iterate through each UV shell in the provided uvShells array
		for index = 1 to uvShells.count do 
		(
			-- Select the faces of the current UV shell
			unwrapModifier.selectFaces uvShells[index]
			
			--Convert the selected faces into selected edges
			unwrapModifier.faceToEdgeSelect()
			
			-- Retrieve the selected edges as a bitarray
			local edgeArray = unwrapModifier.getSelectedEdges()
			
			-- Append the edges for the current UV shell to the uvShellEdgeArray
			append uvShellEdgeArray edgeArray
		)
		-- Return the array containing edge selections for all UV shells
		return uvShellEdgeArray
	),
	
	-- Function to map each edge to its respective vertices
	fn MapUVEdgesToVerticesArray unwrapModifier =
	(
		-- Get the total number of polygons in the UV shell
		local totalPolygonCount = unwrapModifier.numberPolygons()
		
		-- Select all faces in the UV shell
		unwrapModifier.selectFaces #{1..totalPolygonCount}
		
		-- Convert the selected faces into selected edges
		unwrapModifier.faceToEdgeSelect()
		
		-- Get all the edges in a bitarray
		local totalEdgeBArr = unwrapModifier.getSelectedEdges()
		
		-- Get the total number of edges
		local totalEdgesCount = totalEdgeBArr.numberSet
		
		-- Initialize an empty array to store the vertex data for each edge
		local edgeToVertMappingArray = #()
		
		-- Loop through each edge in the selection (totalEdgesCount)
		for edgeIndex = 1 to totalEdgesCount do
		(
			-- Select the current edge
			unwrapModifier.selectEdges #{edgeIndex}
			\
			-- Convert the selected edge into its corresponding vertices
			unwrapModifier.edgeToVertSelect()
			
			-- Get the selected vertices as an array 
			local vertArray = (unwrapModifier.getSelectedVertices()) as array
				
			-- Append the vertex array for the current edge to edgeToVertMappingArray
			append edgeToVertMappingArray vertArray
		)
		
		-- Return the array containing vertex mappings for all edges in the UV shell
		return edgeToVertMappingArray
	),
	
	-- Function to retrieve the position data of all vertices
	fn GetVertexPositionArray unwrapModifier = 
	(
		-- Get the total number of vertices in the UV shell
		local totalVertexCount = unwrapModifier.NumberVertices()
		
		-- Collecting vertToVertPositionArray by iterating all vertices and getting its position
		local vertexPositionArray = for vertexIdx = 1 to totalVertexCount collect (unwrapModifier.getVertexPosition 0 vertexIdx)
		
		-- Return the array containing the positions of all vertices
		return vertexPositionArray
	),
	
	-- Function to check if two edges intersect in the UV space
	fn checkIntersection currEdge nextEdge edgeToVertArray vertToVertPositionArray =
	(
		-- Get the vertex positions of the current edge and the next edge from edgeToVertArray array
		local currEdgeVerts = edgeToVertArray[currEdge]
		local nextEdgeVerts = edgeToVertArray[nextEdge]

		-- Get x and y coordinates of the vertices for the current edge x1, y1, x2, y2
		local x1 = vertToVertPositionArray[currEdgeVerts[1]].x
		local y1 = vertToVertPositionArray[currEdgeVerts[1]].y
		local x2 = vertToVertPositionArray[currEdgeVerts[2]].x
		local y2 = vertToVertPositionArray[currEdgeVerts[2]].y
		
		-- Get x and y coordinates of the vertices for the next edge x3, y3, x4, y4
		local x3 = vertToVertPositionArray[nextEdgeVerts[1]].x
		local y3 = vertToVertPositionArray[nextEdgeVerts[1]].y
		local x4 = vertToVertPositionArray[nextEdgeVerts[2]].x
		local y4 = vertToVertPositionArray[nextEdgeVerts[2]].y
		
		-- Precompute differences for calculating intersection
		local diff1 = y1 - y3
		local diff2 = x1 - x3
		local diff3 = x1 - x2
		local diff4 = y3 - y4
		local diff5 = y1 - y2
		local diff6 = x3 - x4
		
		-- Precompute denominator
		local denom = (diff3) * (diff4) - (diff5) * (diff6)
		
		-- Return early if denominator is zero (parallel lines)
		if (denom == 0) do return false
		
		-- Calculate t and u values
		local t = (((diff2)*(diff4)) - ((diff1)*(diff6))) / denom
		local u = -(((diff3)*(diff1)) - ((diff5)*(diff2))) / denom
		
		-- Intersection condition: both t and u must be in the range [0,1]
		return ((0 <= t and t <= 1) and (0 <= u and u <= 1))
	),
	
	-- Function to traverse through edges of two UV shell elements and check for intersections
	fn traverseEdgeElement currElementEdges nextElementEdges edgeToVertArray vertToVertPositionArray = 
	(
		-- Iterate over each edge in the current UVShell element
		for currEdge in currElementEdges do
		(
			-- Check against each edge in the next UVShell element
			for nextEdge in nextElementEdges do
			(
				-- If edges intersect, return true
				if (checkIntersection currEdge nextEdge edgeToVertArray vertToVertPositionArray) then
				(
					return true
				)
			)
		)
		-- Return false when no intersection found
		return false
	),
	
	-- Function to check for overlapping edges among UV shells
	fn CheckEdgesOverlap uvShellEdgeArray edgeToVertArray vertToVertPositionArray = 
	(
		-- Array to store overlapping UV shell indices
		local overlappedUVShellIdxArray = #()
		
		-- Iterate over each UV shell
		for i = 1 to uvShellEdgeArray.count do
		(
			-- Compare with the subsequent UV shells
			for j = i + 1 to uvShellEdgeArray.count where i != j do
			(
				-- Check if any edges intersect
				local doesEdgesIntersectBool = traverseEdgeElement uvShellEdgeArray[i] uvShellEdgeArray[j] edgeToVertArray vertToVertPositionArray
				
				-- If edges intersect, add the indices to the overlapped array
				if (doesEdgesIntersectBool) do
				(
					overlappedUVShellIdxArray = enterOverlappedUVShellIdxArray overlappedUVShellIdxArray i j
				)
			)
		)
		-- Return array of overlapping UV shell indices
		return overlappedUVShellIdxArray
	),
	
	-- Function to check UV overlap using specified methods (Bounding box or Edge-based)
	-- Parameters:
	-- method: 1 for Bounding Box method, 2 for Edge-based method
	-- selectedObjects: Array of selected objects
	fn CheckUVOverlap selectedObjects method =
	(
		-- Record the start of the time
		local start = timestamp()
		
		-- Ensure only one object is selected
		if (selectedObjects.count == 1) do
		(
			local obj = selectedObjects[1]
		
			-- Ensure the object is an Editable Poly with an Unwrap_UVW modifier
			if(((classOf obj.baseObject) == Editable_Poly) and ((classOf obj.modifiers[obj.modifiers.count]) == Unwrap_UVW)) do
			(
				local unwrapModifier = obj.modifiers[obj.modifiers.count]
				if(unwrapModifier != undefined) do
				(
					-- Disable undo and redraw for performance
					with undo off, redraw off
					(
						-- Retrieve UV shell data
						local uvShells = GetUVShellsFromSelectedFaces unwrapModifier
						
						-- If UV shells exist then process the below code
						if(uvShells.count > 0) do
						(
							-- Bounding box method
							if (method == 1) then
							(
								-- Get minMaxData for the selected UVshells
								local minMaxData = calculateUVShellAreaData unwrapModifier uvShells
								-- Check UVshells for overlap and return the overlapping indices as an array
								local overlappedUVShellIdxArray = CheckBoundsOverlap minMaxData
								-- Replace the Indices array with actual values
								local overlappedUVShellArray = ReplaceIdxArrayWithActualArray uvShells overlappedUVShellIdxArray
								-- Assign smoothing group for the overlapped UV shells based on overlappedUVShellArray
								GroupOverlappedUVShells unwrapModifier overlappedUVShellArray
								format "Bounding box calculation done.\n"
							)
							-- Edge-based method
							else if (method == 2) then
							(
								-- Get the edges for the selected UV shells based on uvShellsArray
								local uvShellEdgeArray = GetUVShellEdgeArray unwrapModifier uvShells
								-- Get the vertices for the edges and store then in an array
								local edgeToVertArray = MapUVEdgesToVerticesArray unwrapModifier
								-- Get all vertex positions and store them in an array
								local vertToVertPositionArray = GetVertexPositionArray unwrapModifier
								-- Check UVshells for overlap and return the overlapping indices as an array
								local overlappedUVShellIdxArray = CheckEdgesOverlap uvShellEdgeArray edgeToVertArray vertToVertPositionArray
								-- Replace the Indices array with actual values
								local overlappedUVShellArray = ReplaceIdxArrayWithActualArray uvShells overlappedUVShellIdxArray
								-- Assign smoothing group for the overlapped UV shells based on overlappedUVShellArray
								GroupOverlappedUVShells unwrapModifier overlappedUVShellArray
								format "Edge method calculation done.\n"
							)
							else
							(
								print "Error with the states\n"
							)
						)
					)
				)
			)
		)
		
		local end = timeStamp()
		format "Processing took % seconds\n" ((end - start) / 1000.0)
	),
	
	-- Function to offset UV coordinates in the Unwrap_UVW modifier
	fn offsetUVCoordinates offsetValue =
	(
		-- Check if the currently selected modifier in the ModPanel is an Unwrap_UVW modifier
		if (classOf (modPanel.getCurrentObject()) == Unwrap_UVW) then
		(
			-- Get the currently active modifier which is Unwrap_UVW
			local unwrapModifier = modPanel.getCurrentObject()
			
			-- Offset the selected UV elements by the given value (offsetVal)
			unwrapModifier.moveSelected offsetValue
		)
		-- If Unwrap_UVW modifier is not present then show the message
		else
		(
			messageBox "Add an UnwrapUVW modifier to the object"
		)
	)
)

-- Declare global variable and intialized it with a new instance of overlappedUV struct.
global overlappedUVInstance = OverlappedUV()
