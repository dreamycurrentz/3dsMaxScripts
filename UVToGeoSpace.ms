fn edgeIntersect currElementEdge nextElementEdge =
(
-- 	format "\nFormat: % %" currElementEdgeIndex nextElementEdgeIndex
	
	currEdgeVerts = polyop.getEdgeVerts obj currElementEdge
-- 	format "\ncurrLineVerts: %" currEdgeVerts
	
	nextEdgeVerts = polyop.getEdgeVerts obj nextElementEdge
-- 	format "\nnextLineVerts: %" nextEdgeVerts
	
	vertPos1 = polyop.getVert obj currEdgeVerts[1]
	vertPos2 = polyop.getVert obj currEdgeVerts[2]
		
	x1 = vertPos1.x
	y1 = vertPos1.y
	x2 = vertPos2.x
	y2 = vertPos2.y
	
	vertPos3 = polyop.getVert obj nextEdgeVerts[1]
	vertPos4 = polyop.getVert obj nextEdgeVerts[2]
	
	x3 = vertPos3.x
	y3 = vertPos3.y
	x4 = vertPos4.x
	y4 = vertPos4.y
	
	t = (((x1-x3)*(y3-y4)) - ((y1-y3)*(x3-x4))) / (((x1-x2)*(y3-y4))-((y1-y2)*(x3-x4)))
	u = -(((x1-x2)*(y1-y3)) - ((y1-y2)*(x1-x3))) / (((x1-x2)*(y3-y4))-((y1-y2)*(x3-x4)))

	Px = (x1 + t * (x2-x1))
	Py = (y1 + t * (y2-y1))
		
	if ((0 <= t and t <= 1) and (0 <= u and u <= 1)) then
	(
		return true
	)
	else
	(
		return false
	)
)

fn elementIntersect currElement nextElement =
(
-- 	print "\nEntered Element Intersect function"
	
	local boolFlag = false
	
	currElementEdges = polyop.getEdgesUsingFace obj currElement
	nextElementEdges = polyop.getEdgesUsingFace obj nextElement
	
-- 	format "currElementEdges: %" currElementEdges
-- 	format "\nnextElementEdges: %" nextElementEdges
-- 	format "\ncurrElementEdgesCount: %" currElementEdges.numberSet
-- 	format "\nnextElementEdgesCount: %" nextElementEdges.numberSet

	if (currElementEdges.count > 0 and nextElementEdges.count > 0) do
	(
		for currElementEdge in currElementEdges do
		(
			for nextElementEdge in nextElementEdges do
			(
-- 				format "\n currElementEdges: % %, nextElementEdges: % %" currElementEdges currElementEdge nextElementEdges nextElementEdge
				boolFlag = edgeIntersect currElementEdge nextElementEdge
				
				if (boolFlag) do
				(
-- 					format "currObjEdgeIndex: %, nextObjEdgeIndex: %" currObjEdgeIndex nextObjEdgeIndex
					return true
				)
			)
		)
	)
	return false
)

fn enterTotalOverlappedArray currElement nextElement boolIntersect = 
(
	local tempArray = #()
	local elementFound = false
	
	if not boolIntersect then
	(
		local elementFoundCurrElement = false
		local elementFoundNextElement = false
		
		if totalOverlappedFacesArray.count == 0 then
		(
			appendIfUnique totalOverlappedFacesArray currElement
			appendIfUnique totalOverlappedFacesArray nextElement
		)
		else
		(
			currElement = currElement as Array
			nextElement = nextElement as Array
			
			for i = 1 to totalOverlappedFacesArray.count do
			(
				for currElementIndex in currElement do
				(
					if (findItem totalOverlappedFacesArray[i] currElementIndex != 0) do					
					(
						elementFoundCurrElement = true
					)
				)
			)
			
			for i = 1 to totalOverlappedFacesArray.count do
			(
				for nextElementIndex in nextElement do
				(
					if (findItem totalOverlappedFacesArray[i] nextElementIndex != 0) do					
					(
						elementFoundNextElement = true
					)
				)
			)
			
			currElement = currElement as BitArray
			nextElement = nextElement as BitArray
			
			
			if elementFoundCurrElement == false do
			(
				appendIfUnique totalOverlappedFacesArray currElement
			)
		
			if elementFoundNextObj == false do
			(
				appendIfUnique totalOverlappedFacesArray nextElement
			)
		)
	)
	
	else
	(
-- 		print "\nEntering else statement"
-- 		print totalOverlappedFacesArray
		
		local elementFoundCurrElement = false
		local elementFoundNextElement = false
		
-- 		currElement = currElement as Array
-- 		nextElement = nextElement as Array

		for i = 1 to totalOverlappedFacesArray.count do
		(
			for currElementIndex in currElement do
			(
				if (findItem totalOverlappedFacesArray[i] currElementIndex != 0) do				
				(
					elementFoundCurrElement = true
-- 					print "CurrElement Found"
					local tempArr = totalOverlappedFacesArray[i] + currElement + nextElement
-- 					format "Temp Array: %" tempArr
					totalOverlappedFacesArray[i] = totalOverlappedFacesArray[i] + tempArr
					return 1
				)
			)
		)
		
		for i = 1 to totalOverlappedFacesArray.count do
		(
			for nextElementIndex in nextElement do
			(
				if (findItem totalOverlappedFacesArray[i] nextElementIndex != 0) do				
				(
					elementFoundNextElement = true
-- 					print "NextElement Found"
					local tempArr = totalOverlappedFacesArray[i] + currElement + nextElement
-- 					format "Temp Array: %" tempArr
					totalOverlappedFacesArray[i] = totalOverlappedFacesArray[i] + tempArr
					return 1
				)
			)
		)
		
		if elementFoundCurrElement == false and elementFoundCurrElement == false do
		(
			local tempArr = currElement + nextElement
			appendIfUnique totalOverlappedFacesArray tempArr
		)
	)
)

fn removeOverlappedFacesArrayDuplicates totalOverlappedFacesArray =
(
	for i = 1 to totalOverlappedFacesArray.count do
	(
		for j = 1 to totalOverlappedFacesArray.count where i != j do
		(
			arr1 = totalOverlappedFacesArray[i]
			arr2 = totalOverlappedFacesArray[j]
			
-- 			format "\n % %"i j
-- 			format "\n % %"arr1 arr2
			
			for arr1CurrVal in arr1 do
			(
				for arr2CurrVal in arr2 do
				(
-- 					format "\n % %"arr1CurrVal arr2CurrVal
					if arr1CurrVal == arr2CurrVal do
					(
-- 						format "\nTot: %" totalOverlappedFacesArray[j]
						for k = totalOverlappedFacesArray[j].count to 1 by -1 do
						(
							appendIfUnique totalOverlappedFacesArray[i] totalOverlappedFacesArray[j][k]
							deleteItem totalOverlappedFacesArray[j] k
						)
					
-- 						format "\nAfter deletion array: %" totalOverlappedFacesArray
					)
				)
			)
		)
	)
)

fn deleteEmptyNestedSubArray totalOverlappedFacesArray =
(
	for i = totalOverlappedFacesArray.count to 1 by -1 do
	(
		if totalOverlappedFacesArray[i].numberSet == 0 do
		(
			deleteItem totalOverlappedFacesArray i
		)
	)
)


-- Get the element faces in an array
-- Main code starts here

-- Get the object
mainObj = $

unwrapMod =  mainObj.modifiers[mainObj.modifiers.count]
selectedFaces = unwrapMod.getSelectedFaces()
collapseStack mainObj

obj = copy mainObj

ChannelInfo.CopyChannel obj 3 1
ChannelInfo.PasteChannel obj 1 1

convertToMesh obj
convertToPoly obj

toDelete = -selectedFaces
polyop.deleteFaces obj toDelete
CenterPivot obj
ResetXForm obj
collapseStack obj

elementFacesArray = #()

-- Initialize a bitarray to track visited faces
visitedFaces = #{}

-- Loop through all the faces of the object
numFaces = polyOp.getNumFaces obj

for f = 1 to numFaces do 
(
    -- If the face has already been processed, skip it
    if visitedFaces[f] then continue
    
    -- Get all the faces that belong to the same element as this face
    elementFaces = polyOp.getElementsUsingFace obj f
    
    -- Mark these faces as visited
    visitedFaces += elementFaces
	
	appendIfUnique elementFacesArray elementFaces
    
    -- Perform operations on the current element
--     format "Processing element with faces: %\n" elementFaces
)

format "\nElement faces Array: %" elementFacesArray


totalOverlappedFacesArray = #()

-- Loop through each one and find the intersection
for i = 1 to elementFacesArray.count do
(
	for j = 1 to elementFacesArray.count where i != j do
	(
		local boolIntersect = false
		
-- 		format "\n\nElementArray[i]: %" elementFacesArray[i]
-- 		format "\nElementArray[j]: %" elementFacesArray[j]
		
		currElement = elementFacesArray[i]
		nextElement = elementFacesArray[j]
		
-- 		format "\nCurrElement: %, nextElement: %" currElement nextElement
		
		boolIntersect = elementIntersect currElement nextElement
		
		
		if (boolIntersect) then
		(
-- 			print "\nEdge intersects"
			
			if (totalOverlappedFacesArray.count == 0) then
			(
-- 				print "Entered empty set"
-- 				format "\nCurrentElement: %, nextElement: %" currElement nextElement
				local joinBitArrayTemp = currElement + nextElement
-- 				format "JoinBitArrayTemp: %" joinBitArrayTemp
				append totalOverlappedFacesArray joinBitArrayTemp
			)
			else
			(
-- 				print "\nArray has something"
-- 				format "\noverlapped array: %" totalOverlappedFacesArray
-- 				format "\nCurrentElement: %, nextElement: %" currElement nextElement
				enterTotalOverlappedArray currElement nextElement boolIntersect
			)
		)
		else
		(
				enterTotalOverlappedArray currElement nextElement boolIntersect
		)
-- 		format "\nTotal overlapped array: %" totalOverlappedFacesArray
	)	
)

removeOverlappedFacesArrayDuplicates totalOverlappedFacesArray
deleteEmptyNestedSubArray totalOverlappedFacesArray

format "\nTotal overlapped array: %" totalOverlappedFacesArray

delete obj

addModifier mainObj unwrapMod
unwrapMod.edit()
unwrapMod.setTVSubObjectMode 3

for i = 1 to totalOverlappedFacesArray.count do
(
	unwrapMod.selectFaces totalOverlappedFacesArray[i]
	unwrapMod.GroupCreateBySelection()
)
