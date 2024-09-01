-- This script gives faces of UV shells in nested array

fn findFace faceBasedOnUVArray value =
(
	faceFound = false
	for i = 1 to faceBasedOnUVArray.count do
	(
		for j = 1 to faceBasedOnUVArray[i].count do
		(
			if value == faceBasedOnUVArray[i][j] do
			(
				faceFound = true
				return faceFound
			)
		)
	)
	return faceFound
)

-- Get the selected object
obj = selection[1]
--Convert to editable mesh
convertToMesh obj

faceBasedOnUVArray = #()

-- Looping till the face count
for i = 1 to obj.numfaces do
(
	format "\n\n Testing index: %" i
	
	format "\n Before checking; faceBasedOnUVArray: %" faceBasedOnUVArray
	format "\n faceBasedOnUVArrayCount: %" faceBasedOnUVArray.count
	
	-- We are checking if face is already found
	faceFound = findFace faceBasedOnUVArray i
	
	face_array = #()
	
	-- Only when face is not found we are entering the if block
	if faceFound == false do
	(
		face_array = #(i)
		cnt = 0
		
		while cnt < face_array.count do
		(		
			cnt += 1
			theVerts = meshop.getMapVertsUsingMapFace obj 1 #(face_array[cnt])
			theFaces = meshop.getMapFacesUsingMapVert obj 1 theVerts
			for f in theFaces where findItem face_array f == 0 do
			(
				append face_array f
			)
		)
		append faceBasedOnUVArray face_array
	)
	format "\n After checking; faceBasedOnUVArray: %" faceBasedOnUVArray
	
)

format "\n Face Based on UV Array: %" faceBasedOnUVArray

