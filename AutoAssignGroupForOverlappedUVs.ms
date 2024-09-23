-- Initialize a totalOverlappedFacesArray to store overlapped faces
totalOverlappedFacesArray = #()

-- 	Initialize an empty array to track UV elementFaces
elementFacesArray = #()

fn hasUVWUnwrapModifier obj =
(
	if (classOf obj.modifiers[obj.modifiers.count] == Unwrap_UVW) then
		return true
	else
		return false
)

-- Function to check if vertices intersect using min max method
fn doesVertIntersect currElementVertMinMax nextElementVertMinMax = 
(	
-- 	Set all the variables
	
-- 	For current element
	currMinX = currElementVertMinMax[1]
	currMinY = currElementVertMinMax[2]
	currMaxX = currElementVertMinMax[3]
	currMaxY = currElementVertMinMax[4]
	
-- 	For target element
	nextMinX = nextElementVertMinMax[1]
	nextMinY = nextElementVertMinMax[2]
	nextMaxX = nextElementVertMinMax[3]
	nextMaxY = nextElementVertMinMax[4]
	
-- 	Min max calculation
	xOverlap = (currMaxX >= nextMinX) and (currMinX <= nextMaxX)
	yOverlap = (currMaxY >= nextMinY) and (currMinY <= nextMaxY)
	
-- 	Return the result
	return (xOverlap and yOverlap)
)

-- Function to update totalOverlappedFacesArray
fn enterTotalArray currElementFaceIndex nextElementFaceIndex = 
(
-- 	Variable to store Overlapping flag
	local isOverlapping = false
	
-- 	Combine elementFacesArray[currElementFaceIndex] + elementFacesArray[nextElementFaceIndex] into a tempArray
	local tempCombinedArray = elementFacesArray[currElementFaceIndex] + elementFacesArray[nextElementFaceIndex]
	
-- 	Loop through totalOverlappedFacesArray
	for i = 1 to totalOverlappedFacesArray.count do
	(
-- 		If the tempCombinedArray and totalOverlappedFacesArray[i] matches
		if (tempCombinedArray * totalOverlappedFacesArray[i]).isEmpty == false then
		(
-- 			Add the tempCombinedArray to totalOverlappedFacesArray[i]
			totalOverlappedFacesArray[i] += tempCombinedArray
			
-- 			Set the overlappingBoolFlag to true
			isOverlapping = true
			
-- 			Continue as we don't want to loop again
			continue
		)
	)
	
-- 	If isOverlapping = false, then we append to totalOverlappedFacesArray
	if not isOverlapping do
	(
		append totalOverlappedFacesArray tempCombinedArray
	)
)


with undo off
(
	with redraw off
	(

-- 		Initialize timestamp
		start = timeStamp()

-- 		Get selection as array
		selectedObj = selection as array
		
-- 		Enter only if one object is selected
		if (selectedObj.count > 0) and (classOf selectedObj[1].baseObject == Editable_Poly)  do
		(
			
-- 			Select the first object
			mainObj = selectedObj[1]
			
			local unwrapMod =  mainObj.modifiers[mainObj.modifiers.count]
			selectedFaces = unwrapMod.getSelectedFaces()
			
			if (hasUVWUnwrapModifier mainObj) then
			(
				local unwrapMod =  mainObj.modifiers[mainObj.modifiers.count]
				local selectedFaces = unwrapMod.getSelectedFaces()
				collapseStack mainObj
				
				-- Copy the selectedObj to another variable called obj
				obj = copy mainObj
				
-- 				local toDelete = -selectedFaces
-- 				polyop.deleteFaces obj toDelete
				
				-- Convert UV to Mesh
				ChannelInfo.CopyChannel obj 3 1
				ChannelInfo.PasteChannel obj 1 1	
				
--	 			Convert to mesh and to poly to treat it like an editable object
-- 				Otherwise it doesn't behave like an editable poly
				convertToMesh obj
				convertToPoly obj
				
				CenterPivot obj
				ResetXForm obj		
				collapseStack obj
				
-- 				Initialize an empty array to store UVElements Vertices min max
				elementVertArray = #()	
				
-- 				Initialize a bitarray to track visited faces
				visitedFaces = #{}

-- 				Get total number of faces in the obj
				numFaces = polyOp.getNumFaces obj
			
-- 				Loop through all the faces of the object
				for f = 1 to numFaces do 
				(
-- 					If the face has already been processed, skip it
					if visitedFaces[f] then continue
				
-- 					Get all the faces that belong to the same element as this face
					elementFaces = polyOp.getElementsUsingFace obj f
				
-- 					Mark these faces as visited
					visitedFaces += elementFaces
				
-- 					Append elementFaces to elementFacesArray
					appendIfUnique elementFacesArray elementFaces
				)

-- 				Print all the faces in the elementFacesArray
				format "elementFacesArray: %\n" elementFacesArray

			
-- 				Initialize a boolFlag variable to store if face overlaps or not
				boolFlag = false
			
				
-- 				Loop through elementFacesArray which contains faces based on UV shells 
				for i = 1 to elementFacesArray.count do
				(
				
					local minPoint = [1e9, 1e9, 1e9]
					local maxPoint = [-1e9, -1e9, -1e9]
				
					local faceVertsCombined = polyOp.getFacesVerts obj elementFacesArray[i]
				
-- 					format "\nFace verts combined: %" faceVertsCombined
				
					local faceVerts = #()
				
-- 					Join all the face verts into bitarray list
					for faceVertIndex = 1 to faceVertsCombined.count do
					(
						faceVerts += faceVertsCombined[faceVertIndex]
					)
				
					faceVerts = (makeUniqueArray faceVerts) as BitArray
				
-- 					format "\nFaceVerts: %" faceVerts
				
					for v in faceVerts do
					(
						local vertPos = polyOp.getVert obj v
-- 						format "\nVert pos: %" vertPos
						minPoint.x  = amin minPoint.x vertPos.x
						minPoint.y = amin minPoint.y vertPos.y
					
						maxPoint.x = amax maxPoint.x vertPos.x
						maxPoint.y = amax maxPoint.y vertPos.y
-- 						format "\nminPoint.x: %" minPoint.x
					)
					
-- 					Appending minPoint.x, minPoint.y, maxPoint.x, maxPoint.y to tempArray
					local tempArray = #()
					tempArray = append tempArray minPoint.x
					tempArray = append tempArray minPoint.y
					tempArray = append tempArray maxPoint.x
					tempArray = append tempArray maxPoint.y
					
-- 					Append tempArray to elementVertArray
					elementVertArray = append elementVertArray tempArray
				)
			
-- 				Loop through elementVertArray
				for i = 1 to elementVertArray.count do
				(
					for j = i + 1 to elementVertArray.count where i != j do
					(
						
-- 						Function to check does elementVertArray[i] and elementVertArray[j] intersect
						boolFlag = doesVertIntersect elementVertArray[i] elementVertArray[j]
						
-- 						If vertices intersect then we send index i and j to enterTotalArray function
						if boolFlag do
						(
							enterTotalArray i j
						)
					)
				)
				
--				format "\nTotal elementVertArray: %" elementVertArray
				format "\nTotal overlapped array: %" totalOverlappedFacesArray
			
-- 				Deleting the obj since we extracted the faces and vertices
				delete obj
			
-- 				Goto modify mode
				max modify mode
				
-- 				Initialize unwrapModifier
				unwrapMod = Unwrap_UVW()
				
-- 				Adding Unwrap modifier to mainObj
				addModifier mainObj unwrapMod
				
-- 				Enter edit mode
				unwrapMod.edit()
				
-- 				Choose SubObjectLevel 3
				unwrapMod.setTVSubObjectMode 3
				
-- 				Deselect all the faces
				unwrapMod.selectFaces #{}
				
-- 				To set Assign Group for overlapped faces, loop through totalOverlappedFacesArray
				for i = 1 to totalOverlappedFacesArray.count do
				(
-- 					Store totalOverlappedFacesArray[i] to tempVariable currFaceSelection
					local currFaceSelection = totalOverlappedFacesArray[i]
					
-- 					Select faces in currFaceSelection
					unwrapMod.selectFaces currFaceSelection
					
-- 					Create group for the current selection
					unwrapMod.GroupCreateBySelection()
					
-- 					Deselect all the selected faces as it will overlap with the next iteration
					unwrapMod.selectFaces #{}
				)
			
				end = timeStamp()
				format "\nProcessing took % seconds\n" ((end - start) / 1000.0)
				
			)
		)
	)
)
