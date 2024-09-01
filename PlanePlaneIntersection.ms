-- Made this script to test and see how edge edge intersection works.
-- In this I have impleted code that works only on objects in 2d space (x, y).


-- This function gets two edges as parameters 
-- It then gets the vertices of the two edges. 
-- Using calculation it returns true if two edges intersect
fn edgeIntersect currObj nextObj currObjEdgeIndex nextObjEdgeIndex = 
(
	currLineVerts = polyop.getEdgeVerts currObj currObjEdgeIndex
	nextLineVerts = polyop.getEdgeVerts nextObj nextObjEdgeIndex
	
	vertPos1 = polyop.getVert currObj currLineVerts[1]
	vertPos2 = polyop.getVert currObj currLineVerts[2]
		
	x1 = vertPos1.x
	y1 = vertPos1.y
	x2 = vertPos2.x
	y2 = vertPos2.y
	
	vertPos3 = polyop.getVert nextObj nextLineVerts[1]
	vertPos4 = polyop.getVert nextObj nextLineVerts[2]
	
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

fn objIntersect currObj nextObj =
(
	boolFlag = false
	
	currObjEdgeCount = polyop.getNumEdges currObj
	nextObjEdgeCount = polyop.getNumEdges nextObj
	
	if (currObjEdgeCount > 0 and nextObjEdgeCount > 0) do
	(
		for currObjEdgeIndex = 1 to currObjEdgeCount do
		(
			for nextObjEdgeIndex = 1 to nextObjEdgeCount do
			(
				boolFlag = edgeIntersect currObj nextObj currObjEdgeIndex nextObjEdgeIndex
				if (boolFlag) do
				(
					print "Edge intersects"
					return true
				)
			)
		)
	)
	return false
)

fn enterTotalOverlappedArray totalOverlappedArray currObj nextObj boolIntersect = 
(
	tempArray = #()
	elementFound = false
	
	if not boolIntersect then
	(
		elementFoundcurrObj = false
		elementFoundNextObj = false
		
		if totalOverlappedArray.count == 0 then
		(
			tempArray = #()
			appendIfUnique tempArray currObj.name
			appendIfUnique totalOverlappedArray tempArray
			tempArray = #()
			appendIfUnique tempArray nextObj.name
			appendIfUnique totalOverlappedArray tempArray
		)
		else
		(
			for i = 1 to totalOverlappedArray.count do
			(
				if (findItem totalOverlappedArray[i] currObj.name != 0) then
				(
					elementFoundcurrObj = true
				)
			)
			
			for i = 1 to totalOverlappedArray.count do
			(
				if (findItem totalOverlappedArray[i] nextObj.name != 0) then
				(
					elementFoundNextObj = true
				)
			)
			
			if elementFoundcurrObj == false do
			(
				tempArray = #()
				appendIfUnique tempArray currObj.name
				appendIfUnique totalOverlappedArray tempArray
			)
			
			if elementFoundNextObj == false do
			(
				tempArray = #()
				appendIfUnique tempArray nextObj.name
				appendIfUnique totalOverlappedArray tempArray
			)
		)
	)
	
	else
	(
		print "\nEntering else statement"
		print totalOverlappedArray
		
		for i = 1 to totalOverlappedArray.count do
		(
			if (findItem totalOverlappedArray[i] currObj.name != 0 or findItem totalOverlappedArray[i] nextObj.name != 0) then
			(
				appendIfUnique totalOverlappedArray[i] currObj.name
				appendIfUnique totalOverlappedArray[i] nextObj.name
				elementFound = true
			)
		)
		
		if elementFound == false do
		(
			appendIfUnique tempArray currObj.name
			appendIfUnique tempArray nextObj.name
			appendIfUnique totalOverlappedArray tempArray
		)
	)
)

fn addNotOverlappedArrays totalOverlappedArray notOverlappedArray = 
(
	elementFound = false
	
	if notOverlappedArray.count == 0 and totalOverlappedArray.count == 0 then
	(
		appendIfUnique totalOverlappedArray notOverlappedArray
	)
	else
	(
		if notOverlappedArray.count > 0 do
		(
			for i = 1 to notOverlappedArray.count do
			(
				elementFound = false
				for j = 1 to totalOverlappedArray.count do
				(
					for k = 1 to totalOverlappedArray[j].count do
					(
						if totalOverlappedArray[j][k] == notOverlappedArray[i] do
						(
							print "Element found"
							print notOverlappedArray[i]
							elementFound = true
						)
					)
				)
				
				if elementFound == false do
				(
					print "Element found false, append element notOverlappedArray[i]"
					appendIfUnique totalOverlappedArray notOverlappedArray[i]
				)
			)
		)
	)
)

fn removeOverlappedFacesArrayDuplicates totalOverlappedArray =
(
	for i = 1 to totalOverlappedArray.count do
	(
		for j = 1 to totalOverlappedArray.count do
		(
			if i != j do
			(
				arr1 = totalOverlappedArray[i]
				arr2 = totalOverlappedArray[j]
				
				format "\n % %"i j
				format "\n % %"arr1 arr2
				
				for arr1CurrVal in arr1 do
				(
					for arr2CurrVal in arr2 do
					(
						format "\n % %"arr1CurrVal arr2CurrVal
						if arr1CurrVal == arr2CurrVal do
						(
							format "\nTot: %" totalOverlappedArray[j]
							for k = totalOverlappedArray[j].count to 1 by -1 do
							(
								appendIfUnique totalOverlappedArray[i] totalOverlappedArray[j][k]
								deleteItem totalOverlappedArray[j] k
							)
						
							format "\nAfter deletion array: %" totalOverlappedArray
						)
					)
				)
			)
		)
	)
)

fn deleteEmptyNestedSubArray totalOverlappedArray =
(
	for i = totalOverlappedArray.count to 1 by -1 do
	(
		if totalOverlappedArray[i].count == 0 do
		(
			deleteItem totalOverlappedArray i
		)
	)
)

-- Starting of code

totalOverlappedArray = #()
notOverlappedArray = #()

-- Get all selected objects as array
selectedObjects = selection as array


-- Enter only if more than 1 objects are selected
if (selectedObjects.count > 1) do
(
	for i = 1 to selectedObjects.count do
	(
		for j = 1 to selectedObjects.count do
		(
			if i != j do
			(
				local boolIntersect = false
				
				local currObj = selectedObjects[i]
				local nextObj = selectedObjects[j]
				
				format "\ncurrObj: %, nextObj: %\n" currObj.name nextObj.name
				
				-- check if both the objects intersect
				boolIntersect = objIntersect currObj nextObj
				print boolIntersect
				
				if (boolIntersect) then
				(
					if (totalOverlappedArray.count == 0) then
					(
						print "Entered empty set"
						currOverlappedArray = #()
						appendIfUnique currOverlappedArray currObj.name
						appendIfUnique currOverlappedArray nextObj.name
						
						appendIfUnique totalOverlappedArray currOverlappedArray
					)
					else
					(
						print "Array has something"
						enterTotalOverlappedArray totalOverlappedArray currObj nextObj boolIntersect
					)
				)
				else
				(
					enterTotalOverlappedArray totalOverlappedArray currObj nextObj boolIntersect
				)
			)
		)
	)
)

format "\nBefore Overlapped Array: %" totalOverlappedArray
		
removeOverlappedFacesArrayDuplicates totalOverlappedArray
deleteEmptyNestedSubArray totalOverlappedArray

format "Total Overlapped Array: %" totalOverlappedArray