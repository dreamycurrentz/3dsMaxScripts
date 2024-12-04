fn hasUVWUnwrapModifier obj =
(
	(classOf obj.modifiers[obj.modifiers.count] == Unwrap_UVW)
)

fn GetSelectedFaces unwrapMod = 
(
	(unwrapMod.getSelectedFaces())
)

fn GetUVShell unwrapMod selectedFaces numFaces =
(	
	
	local selectedFacesArray = selectedFaces as Array
	local uvShells = #()
	
	local unwrapMod_selectFaces = unwrapMod.selectFaces
	
	
	while (selectedFacesArray.count > 0) do
	(
		unwrapMod_selectFaces #{selectedFacesArray[1]}
		unwrapMod.selectElement()
		
		local selectedElementFaces = GetSelectedFaces unwrapMod
		append uvShells selectedElementFaces

		for ele in selectedElementFaces do
		(
			local index = findItem selectedFacesArray ele
			deleteItem selectedFacesArray index
		)
	)
	unwrapMod.selectFaces selectedFaces
	uvShells
)

fn GetUVShellData unwrapMod =
(
	
	local selectedFaces = unwrapMod.getSelectedFaces()
	local numFaces = unwrapMod.numberPolygons()
	
	local uvShells = #()
	
	if (selectedFaces.numberSet > 0) then
	(
		(GetUVShell unwrapMod selectedFaces numFaces)
	) 
	else
	(
		selectedFaces = #{1..numFaces}
		(GetUVShell unwrapMod selectedFaces numFaces)
	)
)

with undo off
(
	with redraw off
	(
		max create mode
		
		selectedObj = selection as array
		
		if (selectedObj.count == 1) and (classOf selectedObj[1].baseObject == Editable_Poly)  do
		(
			obj = selectedObj[1]
			
			if (hasUVWUnwrapModifier obj) do
			(
				start = timestamp()
				
				local unwrapMod =  obj.modifiers[obj.modifiers.count]
				
				local uvShells = GetUVShellData unwrapMod
				format "uvShells: %\n" uvShells
				
				end = timestamp()
				format "\nProcessing took % seconds\n" ((end - start) / 1000.0)
			)
		)
	)
)
max modify mode




/* --------------------------------------
Testing purposes
----------------------------------------- */
-- 	local elementFacesArray = for f = 1 to numFaces where selectedFacesCopy[f] collect
-- 	(
-- 		unwrapMod_selectFaces #{f}
-- 		unwrapMod.selectElement()
-- 		local selectedElement = unwrapMod_getSelectedFaces()
-- 		selectedFacesCopy -= selectedElement
-- 		selectedElement
-- 	)
-- 	elementFacesArray
