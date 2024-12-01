fn hasUVWUnwrapModifier obj =
(
	(classOf obj.modifiers[obj.modifiers.count] == Unwrap_UVW)
)

fn GetUVShell obj unwrapMod selectedFaces numFaces =
(
	local selectedFacesCopy = selectedFaces
	
	local unwrapMod_selectFaces = unwrapMod.selectFaces
	local unwrapMod_selectElement = unwrapMod.selectElement
	local unwrapMod_getSelectedFaces = unwrapMod.getSelectedFaces
	
	local elementFacesArray = for f = 1 to numFaces where selectedFacesCopy[f] collect
	(
		unwrapMod_selectFaces #{f}
		unwrapMod_selectElement()
		local selectedElement = unwrapMod_getSelectedFaces()
		selectedFacesCopy -= selectedElement
		selectedElement
	)
	elementFacesArray
)

fn GetUVShellData obj =
(
	local unwrapMod =  obj.modifiers[obj.modifiers.count]
	local selectedFaces = unwrapMod.getSelectedFaces()
	local numFaces = unwrapMod.numberPolygons()
	
	local uvShells = #()
	
	if (selectedFaces.numberSet > 0) then
	(
		(GetUVShell obj unwrapMod selectedFaces numFaces)
	) 
	else
	(
		selectedFaces = #{1..numFaces}
		(GetUVShell obj unwrapMod selectedFaces numFaces)
	)
)

with undo off
(
	with redraw off
	(
-- 		max create mode
		
		selectedObj = selection as array
		
		if (selectedObj.count == 1) and (classOf selectedObj[1].baseObject == Editable_Poly)  do
		(
			obj = selectedObj[1]
			
			if (hasUVWUnwrapModifier obj) do
			(
				start = timestamp()
				
				local uvShells = GetUVShellData obj
				format "uvShells: %\n" uvShells
				
				end = timestamp()
				format "\nProcessing took % seconds\n" ((end - start) / 1000.0)
			)
		)
	)
)
max modify mode