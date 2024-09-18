fn edgeIntersect currElementEdge nextElementEdge =
(
	
-- 	format "\nFormat: % %" currElementEdgeIndex nextElementEdgeIndex
	
	currEdgeVerts = polyop.getEdgeVerts obj currElementEdge
-- 	format "\ncurrLineVerts: %" currEdgeVerts
	
	nextEdgeVerts = polyop.getEdgeVerts obj nextElementEdge
-- 	format "\nnextLineVerts: %" nextEdgeVerts
	
	vertPos1 = polyop.getVert obj currEdgeVerts[1]
	vertPos2 = polyop.getVert obj currEdgeVerts[2]
	vertPos3 = polyop.getVert obj nextEdgeVerts[1]
	vertPos4 = polyop.getVert obj nextEdgeVerts[2]
		
	x1 = vertPos1.x
	y1 = vertPos1.y
	x2 = vertPos2.x
	y2 = vertPos2.y
	
	x3 = vertPos3.x
	y3 = vertPos3.y
	x4 = vertPos4.x
	y4 = vertPos4.y
	
	denominator = ((x1-x2)*(y3-y4)) - ((y1-y2)*(x3-x4))
	
	if denominator == 0 do return false
	
	t = (((x1-x3)*(y3-y4)) - ((y1-y3)*(x3-x4))) / denominator
	u = -(((x1-x2)*(y1-y3)) - ((y1-y2)*(x1-x3))) / denominator
		
	if ((0 <= t and t <= 1) and (0 <= u and u <= 1)) then
	(
		return true
	)
	else
	(
		return false
	)
)

fn doesEdgeIntersect currElementEdgesArray nextElementEdgesArray = 
(
	local boolFlagIntersect = false
	
	for i = 1 to currElementEdgesArray.count do
	(
		for j = 1 to nextElementEdgesArray.count do
		(
			boolFlagIntersect = edgeIntersect currElementEdgesArray[i] nextElementEdgesArray[j]
			
			if boolFlagIntersect do 
			(
				boolFlagIntersect = true
				return boolFlagIntersect
			)
		)
	)
	return boolFlagIntersect
)

fn enterTotalArray currElementFaceIndex nextElementFaceIndex = 
(
	local isOverlapping = false
	
	if totalOverlappedFacesArray.count == 0 then
	(
		tempArray = elementFacesArray[currElementFaceIndex] + elementFacesArray[nextElementFaceIndex]
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


max create mode

-- Code starts here
start = timeStamp()
mainObj = $

obj = copy mainObj

ChannelInfo.CopyChannel obj 3 1
ChannelInfo.PasteChannel obj 1 1

convertToMesh obj
convertToPoly obj

elementFacesArray = #()
elementEdgesArray = #()
elementEdgesBitArray = #{}

-- Initialize a bitarray to track visited faces
visitedFaces = #{}

-- Loop through all the faces of the object
numFaces = polyOp.getNumFaces obj

for f = 1 to numFaces do 
(
    -- If the face has already been processed, skip it
    if visitedFaces[f] then continue
    
	local combinedEdgeArr = #()
	
    -- Get all the faces that belong to the same element as this face
    elementFaces = polyOp.getElementsUsingFace obj f
	elementEdges = polyOp.getFacesEdges obj elementFaces
    
    -- Mark these faces as visited
    visitedFaces += elementFaces
	
	for i = 1 to elementEdges.count do
	(
		join combinedEdgeArr elementEdges[i]
	)
	
	combinedEdgeArr = makeUniqueArray combinedEdgeArr
	
	appendIfUnique elementFacesArray elementFaces
	appendIfUnique elementEdgesArray combinedEdgeArr
)

format "elementFacesArray: %\n" elementFacesArray
format "elementEdgesArray: % %\n" elementEdgesArray elementEdgesArray.count

totalOverlappedFacesArray = #()

boolFlag = false

for i = 1 to elementEdgesArray.count do
(
	
-- 	Compare each and every edge to every other edge
	for j = i + 1 to elementEdgesArray.count where i != j do
	(
-- 		format "\nelementEdgesArray count: % \n" elementEdgesArray[i].count
-- 		format "NextelementEdgesArray count: % \n" elementEdgesArray[j].count
-- 		format "Element i[%]: %\n" i elementEdgesArray[i]
-- 		format "Element j[%]: %\n" j elementEdgesArray[j]
		
		booLFlag = doesEdgeIntersect elementEdgesArray[i] elementEdgesArray[j]
		if boolFlag do
		(
			enterTotalArray i j
		)
	)
)

format "\nTotal overlapped array: %" totalOverlappedFacesArray

end = timeStamp()
format "Processing took % seconds\n" ((end - start) / 1000.0)
