fn hasUVWUnwrapModifier obj =
(
	(classOf obj.modifiers[obj.modifiers.count] == Unwrap_UVW)
)


fn doesEdgeIntersect currElementVertMinMax nextElementVertMinMax = 
(	
	currMinX = currElementVertMinMax[1]
	currMinY = currElementVertMinMax[2]
	currMaxX = currElementVertMinMax[3]
	currMaxY = currElementVertMinMax[4]
	
	nextMinX = nextElementVertMinMax[1]
	nextMinY = nextElementVertMinMax[2]
	nextMaxX = nextElementVertMinMax[3]
	nextMaxY = nextElementVertMinMax[4]
	
	xOverlap = (currMaxX >= nextMinX) and (currMinX <= nextMaxX)
	yOverlap = (currMaxY >= nextMinY) and (currMinY <= nextMaxY)
	
	return (xOverlap and yOverlap)
)

fn enterTotalArray currElementFaceIndex nextElementFaceIndex = 
(
	local isOverlapping = false
	
	local tempCombinedArray = elementFacesArray[currElementFaceIndex] + elementFacesArray[nextElementFaceIndex]
	
-- 	local counter = 1
-- 	
-- 	while ((not isOverlapping) and (counter <= totalOverlappedFacesArray.count)) do
-- 	(
-- 		if (tempCombinedArray * totalOverlappedFacesArray[counter]).isEmpty == false then
-- 		(
-- 			totalOverlappedFacesArray[counter] += tempCombinedArray
-- 			isOverlapping = true
-- 		)
-- 		counter += 1
-- 	)
-- 	
-- 	if not isOverlapping do
-- 	(
-- 		append totalOverlappedFacesArray tempCombinedArray
-- 	)
	
	
	for i = 1 to totalOverlappedFacesArray.count do
	(
		if (tempCombinedArray * totalOverlappedFacesArray[i]).isEmpty == false then
		(
			totalOverlappedFacesArray[i] += tempCombinedArray
			isOverlapping = true
			break
		)
	)
	
	if not isOverlapping do
	(
		append totalOverlappedFacesArray tempCombinedArray
	)

)

fn getElementFacesArray obj selectedFaces = 
(
	format "\nSelected faces %\n" selectedFaces
	
	visitedFaces = #{}
	
	polyOp_getElementsUsingFace = polyOp.getElementsUsingFace
	
	local numfaces = polyOp.getNumFaces obj
	local faces = (for i = 1 to numfaces where (selectedFaces[i] != false) collect i) as BitArray
	
-- 	format "\nFaces: %\n" faces
	
-- 	local counter = 1
-- 	for f in faces where faces[f] do
-- 	(
-- 		local elementFaces = polyOp_getElementsUsingFace obj f
-- 		faces -= elementFaces
-- 		append elementFacesArray elementFaces
-- 		counter += 1
-- 	)
	
	local numfaces = polyOp.getNumFaces obj
	local faces = (for i = 1 to numfaces collect i) as BitArray
	for f = 1 to numFaces where faces[f] do
	(
		local elementFaces = polyOp_getElementsUsingFace obj f
		faces -= elementFaces
		append elementFacesArray elementFaces
	)
)

totalOverlappedFacesArray = #()
elementFacesArray = #()

with undo off
(
	with redraw off
	(
		max create mode
		
		selectedObj = selection as array
		
		if (selectedObj.count == 1) and (classOf selectedObj[1].baseObject == Editable_Poly)  do
		(
			
			mainObj = selectedObj[1]
-- 			unwrapMod = Unwrap_UVW()
-- 			addModifier mainObj unwrapMod

			local unwrapMod =  mainObj.modifiers[mainObj.modifiers.count]
			selectedFaces = unwrapMod.getSelectedFaces()
						
			if (hasUVWUnwrapModifier mainObj) then
			(
				obj = copy mainObj
				ChannelInfo.CopyChannel obj 3 1
				ChannelInfo.PasteChannel obj 1 1
				ResetXForm obj
				convertToMesh obj
				convertToPoly obj
				
				elementVertArray = #()
				
				getElementFacesArray obj selectedFaces
				format "elementFacesArray: %\n" elementFacesArray
				
				boolFlag = false
				
				polyOp_getVertsUsingFace = polyop.getVertsUsingFace
				
				elementFaceVertsArray = #()
				elementFacesArray_Count = elementFacesArray.count
				
				elementFaceVertsArray = for i = 1 to elementFacesArray_Count collect (polyOp_getVertsUsingFace obj elementFacesArray[i])
				format "\nelementFaceVertsArray: %\n" elementFaceVertsArray
				
				polyOp_getVert = polyOp.getVert
				
				start = timeStamp()

-- 				for i = 1 to elementFaceVertsArray.count do
-- 				(
-- 					local minX = 1e9
-- 					local minY = 1e9
-- 					local maxX = -1e9
-- 					local maxY = -1e9
-- 					
-- 					local vertPos = for v in elementFaceVertsArray[i] collect polyOp_getVert obj v	
-- 				)
-- 				print vertPos
					
-- 				for i = 1 to elementFacesArray.count do
-- 				(
-- 					local minX = 1e9
-- 					local minY = 1e9
-- 					local maxX = -1e9
-- 					local maxY = -1e9
-- 					
-- 					local verts = elementFaceVertsArray[i]
-- 					
-- 					for v in verts do
-- 					(
-- 						local vertPos = polyOp_getVert obj v
-- 						local vx = vertPos.x
-- 						local vy = vertPos.y
-- 						
-- 						if vx < minX then minX = vx
-- 						if vy < minY then minY = vy
-- 						if vx > maxX then maxX = vx							
-- 						if vy > maxY then maxY = vy
-- 					)
-- 					
-- 					append elementVertArray #(minX, minY, maxX, maxY)
-- 				)
				
				
				for i = 1 to elementFaceVertsArray.count do
				(
					local minPoint = [1e9, 1e9, 1e9]
					local maxPoint = [-1e9, -1e9, -1e9]

					for v in elementFaceVertsArray[i] do
					(
						local vertPos = polyOp_getVert obj v
						
						minPoint.x  = amin minPoint.x vertPos.x
						minPoint.y = amin minPoint.y vertPos.y
						maxPoint.x = amax maxPoint.x vertPos.x
						maxPoint.y = amax maxPoint.y vertPos.y
					)
					append elementVertArray #(minPoint.x, minPoint.y, maxPoint.x, maxPoint.y)
				)
-- 				
				format "\nelementVertArray: %" elementVertArray
				
				for i = 1 to elementVertArray.count do
				(
					for j = i + 1 to elementVertArray.count where i != j do
					(
						
						boolFlag = doesEdgeIntersect elementVertArray[i] elementVertArray[j]
						
						if boolFlag do
						(
							enterTotalArray i j
						)
					)
				)
				
				format "\nTotal overlapped array: %" totalOverlappedFacesArray
			
				delete obj
			
				unwrapMod.setTVSubObjectMode 3
				unwrapMod.selectFaces #{}
				
				for i = 1 to totalOverlappedFacesArray.count do
				(
					local currFaceSelection = totalOverlappedFacesArray[i]
					unwrapMod.selectFaces currFaceSelection
					unwrapMod.GroupCreateBySelection()
					unwrapMod.selectFaces #{}
				)
				
				end = timeStamp()
				format "\nProcessing took % seconds\n" ((end - start) / 1000.0)
				
			)
		)
	)
)
max modify mode
