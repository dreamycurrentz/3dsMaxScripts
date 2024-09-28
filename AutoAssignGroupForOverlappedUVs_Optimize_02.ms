/*
fn hasUVWUnwrapModifier obj =
(
	if (classOf obj.modifiers[obj.modifiers.count] == Unwrap_UVW) then
		return true
	else
		return false
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

fn getElementFacesArray obj = 
(
	local numfaces = polyOp.getNumFaces obj
	
	local faces = (for i = 1 to numfaces collect i) as BitArray
	
	polyOp_getElementsUsingFace = polyOp.getElementsUsingFace
	
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
		
		start = timeStamp()
		selectedObj = selection as array
		
		if (selectedObj.count > 0) and (classOf selectedObj[1].baseObject == Editable_Poly)  do
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
				
				getElementFacesArray obj
-- 				format "elementFacesArray: %\n" elementFacesArray
				
				boolFlag = false
				
				polyOp_getVertsUsingFace = polyop.getVertsUsingFace
				
				elementFaceVertsArray = #()
				elementFacesArray_Count = elementFacesArray.count
				
				elementFaceVertsArray = for i = 1 to elementFacesArray_Count collect (polyOp_getVertsUsingFace obj elementFacesArray[i])
-- 				format "\nelementFaceVertsArray: %\n" elementFaceVertsArray
				
				polyOp_getVert = polyOp.getVert
				
				
				
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
				
-- 				format "\nelementVertArray: %" elementVertArray
				
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
				
-- 				format "\nTotal overlapped array: %" totalOverlappedFacesArray
			
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
*/

/*
-- Testing for materials. Kindly ignore
obj = $
currMat = obj.material
currMat1 = copy currMat

multiMat = MultiMaterial numsubs: 2
multiMat.materialList[1] = currMat
multiMat.materialList[2] = currMat1


unwrapMod =  obj.modifiers[obj.modifiers.count]
selectedFaces = unwrapMod.getSelectedFaces()

-- format "\nSelected faces: %" selectedFaces

for f in selectedFaces do
(
	polyop.setFaceMatID obj f 2
)

obj.material = multiMat
*/