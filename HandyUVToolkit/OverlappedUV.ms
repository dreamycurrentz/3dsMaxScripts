fileIn "C:\\Users\\akash\\Desktop\\MaxScriptsPractice\\UVMaster\\UVMaster_01.ms"

struct OverlappedUV
(
	selectedFaces = #(),
	minMaxData = #(),
	overlappedUVShellIdxArray = #(),
	overlappedUVShellArray = #(),
	selectedFacesBitArray = #(),
	uvShellEdgeArray = #(),
	
	fn GetAreaUVShells unwrapMod uvShells =
	(
		local x = 0, y = 0, width = 0, height = 0, areaUVW = 0, areaGeom = 0

		if (uvShells.count > 0) do
		(
			minMaxData = for i = 1 to uvShells.count collect
			(
				unwrapMod.getArea uvShells[i] &x &y &width &height &areaUVW &areaGeom
				#(x, y, width, height)
			)
		)
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
		
		-- Variable to store all the faces in a bitarray
		selectedFacesBitArray = #{}
		
		-- Loop through the uvShells array and add the bitarray to selectedFacesBitArray 
		for element in uvShells do join selectedFacesBitArray element
			
		-- Select the faces in selectedFacesBitArray
		unwrapMod.selectFaces selectedFacesBitArray
					
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
	
	fn CheckBoundsOverlap =
	(
		local breakLoop = false
		local counter = 0
		
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
					if (overlappedUVShellIdxArray.count == 0) then
					(
						append overlappedUVShellIdxArray #{i,j}
					)
					else
					(
						breakLoop = false
						counter = 1
						
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
				)
			)
		)
	),
	
	
	-- Replace overlappedUVShellIdxArray with values from uvShells
	fn ReplaceIdxArrayWithActualArray uvShells =
	(
		-- Collect the array in overlappedUVShellArray
		overlappedUVShellArray = for overlappedUVShellIdx in overlappedUVShellIdxArray collect
		(
			local newSet = #{}
			for idx in overlappedUVShellIdx do newSet += uvShells[idx]
			newSet
		)
	),	
	
	-- Assign groups for overlapped faces by looping overlappedUVShellArray
	fn AssignSmoothingGroup unwrapMod =
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
		
		unwrapMod.selectFaces selectedFacesBitArray
	),
	
	fn CheckUVOverlapBoundingMethod selectedObjects =
	(
		if (selectedObjects.count == 1) do
		(
			local obj = selectedObjects[1]
			
			if(((classOf obj.baseObject) == Editable_Poly) and ((classOf obj.modifiers[obj.modifiers.count]) == Unwrap_UVW)) do
			(
				local unwrapMod = obj.modifiers[obj.modifiers.count]
				
				if(unwrapMod != undefined) do
				(
					uvShells = GetUVShellData unwrapMod
					
					if(uvShells.count > 0) do
					(
						GetAreaUVShells unwrapMod uvShells
						CheckBoundsOverlap()
						ReplaceIdxArrayWithActualArray uvShells
						AssignSmoothingGroup unwrapMod
					)
				)
			)
		)
	),
	
	fn GetUVShellEdgeArray unwrapMod uvShells =
	(
		overlappedUVShellEdgeArray = #()
		
		format "UVShells; %\n" uvShells
		for index = 1 to uvShells.count do 
		(
			unwrapMod.selectFaces uvShells[index]
			unwrapMod.faceToEdgeSelect()
			
			local edgeArray = unwrapMod.getSelectedEdges()
			append uvShellEdgeArray edgeArray
		)
		
		format "uvShellEdgeArray: %\n" uvShellEdgeArray
	),
	
	fn traverseEdgeElement currElementEdges nextElementEdges = 
	(
-- 		for currEdge in currElementEdges do
-- 		(
-- 			for nextEdge in nextElementEdges do
-- 			(
-- 				if (checkIntersection currEdge nextEdge) then
-- 					return true
-- 			)
-- 		)
		return false
	),
	
	fn CheckUVOverlapEdgeMethod selectedObjects = 
	(
		if (selectedObjects.count == 1) do
		(
			local obj = selectedObjects[1]
			
			if(((classOf obj.baseObject) == Editable_Poly) and ((classOf obj.modifiers[obj.modifiers.count]) == Unwrap_UVW)) do
			(
				local unwrapMod = obj.modifiers[obj.modifiers.count]
				
				if(unwrapMod != undefined) do
				(
					uvShells = GetUVShellData unwrapMod
					
					if(uvShells.count > 0) do
					(
						-- Get Element Edges in an array
						GetUVShellEdgeArray unwrapMod uvShells
						
-- 						local doesEdgesIntersectBool = false
		 				for i = 1 to uvShellEdgeArray.count do
		 				(
		 					for j = i + 1 to uvShellEdgeArray.count where i != j do
		 					(
		 						doesEdgesIntersectBool = traverseEdgeElement uvShellEdgeArray[i] uvShellEdgeArray[j]
-- 								
-- 		 						if (doesEdgesIntersectBool == true) do
-- 		 						(
-- 		 							format "\nEdge % and % intersects" elementEdgesArray[i] elementEdgesArray[j]
-- 		 						)
		 					)
		 				)

						
						
						
-- 						Get EdgesInAnArray
-- 						Get VertToVertArray
						
-- 						GetAreaUVShells unwrapMod uvShells
-- 						CheckBoundsOverlap()
-- 						ReplaceIdxArrayWithActualArray uvShells
-- 						AssignSmoothingGroup unwrapMod
					)
				)
			)
		)
	)
)

overlappedUVInstance = OverlappedUV()
selectedObjects = (selection as array)
overlappedUVInstance.CheckUVOverlapEdgeMethod selectedObjects
-- overlappedUVInstance.CheckUVOverlapBoundingMethod selectedObjects