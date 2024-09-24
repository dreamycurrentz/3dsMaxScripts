totalOverlappedFacesArray = #()
elementFacesArray = #()

fn hasUVWUnwrapModifier obj =
(
	if (classOf obj.modifiers[obj.modifiers.count] == Unwrap_UVW) then
		return true
	else
		return false
)


fn doesVertIntersect currElementVertMinMax nextElementVertMinMax = 
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


with undo off
(
	with redraw off
	(

		start = timeStamp()

		selectedObj = selection as array
		
		if (selectedObj.count > 0) and (classOf selectedObj[1].baseObject == Editable_Poly)  do
		(
			
			mainObj = selectedObj[1]
			
			local unwrapMod =  mainObj.modifiers[mainObj.modifiers.count]
			selectedFaces = unwrapMod.getSelectedFaces()
			
			if (hasUVWUnwrapModifier mainObj) then
			(
				local unwrapMod =  mainObj.modifiers[mainObj.modifiers.count]
				local selectedFaces = unwrapMod.getSelectedFaces()
				collapseStack mainObj
			
				obj = copy mainObj
				
				ChannelInfo.CopyChannel obj 3 1
				ChannelInfo.PasteChannel obj 1 1	
				convertToMesh obj
				convertToPoly obj
				CenterPivot obj
				ResetXForm obj		
				collapseStack obj
				
				elementVertArray = #()	
				
				visitedFaces = #{}
				numFaces = polyOp.getNumFaces obj
			

				for f = 1 to numFaces do 
				(
					if visitedFaces[f] then continue
					elementFaces = polyOp.getElementsUsingFace obj f
					visitedFaces += elementFaces
					appendIfUnique elementFacesArray elementFaces
				)
				format "elementFacesArray: %\n" elementFacesArray

				boolFlag = false
			
				for i = 1 to elementFacesArray.count do
				(
				
					local minPoint = [1e9, 1e9, 1e9]
					local maxPoint = [-1e9, -1e9, -1e9]
				
					local faceVertsCombined = polyOp.getFacesVerts obj elementFacesArray[i]
				
					local faceVerts = #()
			
					for faceVertIndex = 1 to faceVertsCombined.count do
					(
						faceVerts += faceVertsCombined[faceVertIndex]
					)
				
					faceVerts = (makeUniqueArray faceVerts) as BitArray
				
					for v in faceVerts do
					(
						local vertPos = polyOp.getVert obj v
						minPoint.x  = amin minPoint.x vertPos.x
						minPoint.y = amin minPoint.y vertPos.y
					
						maxPoint.x = amax maxPoint.x vertPos.x
						maxPoint.y = amax maxPoint.y vertPos.y
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
						boolFlag = doesVertIntersect elementVertArray[i] elementVertArray[j]
						
						if boolFlag do
						(
							enterTotalArray i j
						)
					)
				)
				
				format "\nTotal overlapped array: %" totalOverlappedFacesArray
			
				delete obj
			
				max modify mode
				unwrapMod = Unwrap_UVW()
				addModifier mainObj unwrapMod
				unwrapMod.edit()
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


/* Testing for materials. Kindly ignore
obj = $selection[1]
currMat = obj.material
currMat1 = copy currMat

multiMat = MultiMaterial numsubs: 2
multiMat.materialList[1] = obj.material
multiMat.materialList[2] = obj.material


unwrapMod =  obj.modifiers[obj.modifiers.count]
selectedFaces = unwrapMod.getSelectedFaces()

format "\nSelected faces: %" selectedFaces

for f in selectedFaces do
(
	polyop.setFaceMatID obj f 2
)

obj.material = multiMat
*/
