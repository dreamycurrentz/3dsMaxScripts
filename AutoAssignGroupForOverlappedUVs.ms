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
	local isOverlapping = false
	
	if totalOverlappedFacesArray.count == 0 then
	(
		local tempArray = elementFacesArray[currElementFaceIndex] + elementFacesArray[nextElementFaceIndex]
		append totalOverlappedFacesArray tempArray
	)
	else
	(
		local tempCombinedArray = elementFacesArray[currElementFaceIndex] + elementFacesArray[nextElementFaceIndex]
		
		for i = 1 to totalOverlappedFacesArray.count do
		(
			if (tempCombinedArray * totalOverlappedFacesArray[i]).isEmpty == false then
			(
				totalOverlappedFacesArray[i] += tempCombinedArray
				isOverlapping = true
				continue
			)
		)
		
		 if not isOverlapping do
		(
			append totalOverlappedFacesArray tempCombinedArray
		)
	)
)

with undo off
(
	with redraw off
	(
		
		max create mode
		
-- 		Get selection as array
		selectedObj = selection as array
		
-- 		Enter only if one object is selected
		if (selectedObj.count > 0) and (classOf selectedObj[1] == Editable_Poly)  do
		(
-- 			Select the first object
			mainObj = selectedObj[1]
			
-- 			Initialize timestamp
			start = timeStamp()
		
-- 			Copy the selectedObj to another variable called obj
			obj = copy mainObj

-- 			Convert UV to Mesh
			ChannelInfo.CopyChannel obj 3 1
			ChannelInfo.PasteChannel obj 1 1

-- 			Convert to mesh and to poly to treat it like an editable object
-- 			Otherwise it doesn't behave like an editable poly
			convertToMesh obj
			convertToPoly obj

-- 			Initialize an empty array to track UV elementFaces
			elementFacesArray = #()
			
-- 			Initialize an empty array to store UVelements Vertices min max
			elementVertArray = #()

-- 			Initialize a bitarray to track visited faces
			visitedFaces = #{}

-- 			Get total number of faces in the obj
			numFaces = polyOp.getNumFaces obj

-- 			Loop through all the faces of the object
			for f = 1 to numFaces do 
			(
-- 				If the face has already been processed, skip it
				if visitedFaces[f] then continue
				
-- 				Get all the faces that belong to the same element as this face
				elementFaces = polyOp.getElementsUsingFace obj f
				
-- 				Mark these faces as visited
				visitedFaces += elementFaces
				
-- 				Append elementFaces to elementFacesArray
				appendIfUnique elementFacesArray elementFaces
			)

-- 			Print all the faces in the elementFacesArray
			format "elementFacesArray: %\n" elementFacesArray

-- 			Initialize a totalOverlappedFacesArray to store overlapped faces
			totalOverlappedFacesArray = #()
			
-- 			Initialize a boolFlag variable to store if face overlaps or not
			boolFlag = false
			
			
-- 			Loop through elementFacesArray which contains faces based on UV shells 
			for i = 1 to elementFacesArray.count do
			(
				
				local minPoint = [1e9, 1e9, 1e9]
				local maxPoint = [-1e9, -1e9, -1e9]
				
				local faceVertsCombined = polyOp.getFacesVerts obj elementFacesArray[i]
				
	-- 			format "\nFace verts combined: %" faceVertsCombined
				
				local faceVerts = #()
				
	-- 			Join all the face verts into bitarray list
				for faceVertIndex = 1 to faceVertsCombined.count do
				(
					faceVerts += faceVertsCombined[faceVertIndex]
				)
				
				faceVerts = (makeUniqueArray faceVerts) as BitArray
				
	-- 			format "\nFaceVerts: %" faceVerts
				
				for v in faceVerts do
				(
					local vertPos = polyOp.getVert obj v
	-- 				format "\nVert pos: %" vertPos
					minPoint.x  = amin minPoint.x vertPos.x
					minPoint.y = amin minPoint.y vertPos.y
					
					maxPoint.x = amax maxPoint.x vertPos.x
					maxPoint.y = amax maxPoint.y vertPos.y
	-- 				format "\nminPoint.x: %" minPoint.x
				)
				
				local tempArray = #()
				tempArray = append tempArray minPoint.x
				tempArray = append tempArray minPoint.y
				tempArray = append tempArray maxPoint.x
				tempArray = append tempArray maxPoint.y
				
				elementVertArray = append elementVertArray tempArray
			)
			
			for i = 1 to elementVertArray.count do
			(
				for j = i + 1 to elementVertArray.count where i != j do
				(
	-- 				format "\nElementArrayI: %, ElementArrayJ: %" i j
					
					boolFlag = doesVertIntersect elementVertArray[i] elementVertArray[j]
					if boolFlag do
					(
						enterTotalArray i j
					)
				)
			)
			
	-- 		format "\nTotal elementVertArray: %" elementVertArray
			format "\nTotal overlapped array: %" totalOverlappedFacesArray
			
			delete obj
			
			max modify mode
			unwrapMod = Unwrap_UVW()
			addModifier mainObj unwrapMod
			unwrapMod.edit()
			unwrapMod.setTVSubObjectMode 3
			
			for i = 1 to totalOverlappedFacesArray.count do
			(
				local faceSelection = totalOverlappedFacesArray[i]
				
				unwrapMod.selectFaces #{}
				unwrapMod.selectFaces faceSelection
				unwrapMod.GroupCreateBySelection()
				
			)
			unwrapMod.selectFaces #{}
			end = timeStamp()
			format "\nProcessing took % seconds\n" ((end - start) / 1000.0)		
		)
	)
)

