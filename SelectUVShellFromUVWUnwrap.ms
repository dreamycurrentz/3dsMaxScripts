-- This script gets the UVShell from the selected faces and stores in an array of bitarrays. 
-- Here's how the return type looks like
-- uvShell= #(#{},#{}..)
-- If none is selected then it selects all the faces and returns the UVShells.

(
	struct UVMaster
	(
		-- Checks if the Unwrap_UVW modifier is applied and returns a boolean
		fn HasUVWUnwrapModifier obj =
		(
			return (classOf obj.modifiers[obj.modifiers.count] == Unwrap_UVW)
		),
		
		-- Gets the selected faces and returns it
		fn GetSelectedFaces unwrapMod = 
		(
			return (unwrapMod.getSelectedFaces())
		),
		
		-- Returns the total number of polygons present in the object
		fn GetFaceCount unwrapMod =
		(
			return (unwrapMod.numberPolygons())
		),
		
		-- Selects the faces based on the bitarray passed
		fn SelectFaces unwrapMod selectedFacesBitArray = 
		(
			unwrapMod.selectFaces selectedFacesBitArray
		),
		
		-- Returns UVShell from selectedfaces in an array of bitarrays
		fn GetUVShell unwrapMod selectedFaces numFaces uvShells =
		(
			-- Convert the selectedFaces to array and store it in a variable
			local selectedFacesArray = selectedFaces as Array
			
			-- Loop that runs till selectedFacesArray is 0
			while (selectedFacesArray.count > 0) do
			(
				-- Select the face of the first element in selectedFacesArray
				SelectFaces unwrapMod #{selectedFacesArray[1]}
				
				-- Selects the elements from the faceSelection (from the above step)
				unwrapMod.selectElement()
				
				-- Gets the selected faces
				local selectedElementFaces = GetSelectedFaces unwrapMod
				-- Append the selectedElementFaces to the uvShells array
				append uvShells selectedElementFaces
				
				-- Loop to iterate selectedElementFaces
				for element in selectedElementFaces do
				(
					-- Gets the index of element in selectedFacesArray
					local index = findItem selectedFacesArray element
					
					-- If index is present then delete the item in selectedFacesArray.
					if (index != 0) do
					(
						deleteItem selectedFacesArray index
					)
				)
			)
			
			-- Initializes a new variable to store all the faces in a bitarray
			local selectedFacesBitArray = #{}
			
			-- Loop through the uvShells array and add the bitarray to selectedFacesBitArray 
			for element in uvShells do join selectedFacesBitArray element
				
			-- Select the faces in selectedFacesBitArray
			SelectFaces unwrapMod selectedFacesBitArray
						
			-- Return UV shells
			return uvShells
		),
		
		-- Function to get GetUVShellData
		fn GetUVShellData unwrapMod =
		(
			-- Get selected faces
			local selectedFaces = (GetSelectedFaces unwrapMod)
			
			-- Get total Faces in the object
			local totalFaceCount = (GetFaceCount unwrapMod)
			
			-- Variable to store uvShells
	 		local uvShells = #()
			
			-- If selected Faces is none then select all the faces
			if selectedFaces.isEmpty do selectedFaces = #{1..totalFaceCount}
		
			-- Returns UV shell data
			return (GetUVShell unwrapMod selectedFaces totalFaceCount uvShells)
		)
	)


	with undo off, with redraw off
	(
		-- Get selection as array
		local selectedObjects = selection as array
		
		-- Process only if one object is selected and that object is of type Editable_Poly
		if (selectedObjects.count == 1) and (classOf selectedObjects[1].baseObject == Editable_Poly)  do
		(
			-- Start timestamp
			local start = timestamp()
			
			-- Get the first selected object
			local obj = selectedObjects[1]
			
			-- Create an instance of the struct UVMaster
			local uvMasterInstance = UVMaster()
			
			-- If Unwrap_UVW Modifier is not present then add it
			if not (uvMasterInstance.HasUVWUnwrapModifier obj) then
			(
				local unwrapMod = Unwrap_UVW()
				addModifier obj unwrapMod
			)
			-- If Unwrap_UVW Modifier is present then get the top most modifier which should be Unwrap_UVW
			else
			(
				local unwrapMod = obj.modifiers[obj.modifiers.count]
			)
			
			-- GetUVShellData is being called from uvMasterInstance
			local uvShells = uvMasterInstance.GetUVShellData unwrapMod
			format "uvShells: %\n" uvShells
			
			-- End timestamp
			local end = timestamp()
			format "\nProcessing took % seconds\n" ((end - start) / 1000.0)
		)
	)
)
