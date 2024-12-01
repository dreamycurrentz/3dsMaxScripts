-- Function to check if Unwrap_UVW is applied and on the top of the stack
fn hasUVWUnwrapModifier obj =
(
	(classOf obj.modifiers[obj.modifiers.count] == Unwrap_UVW)
)


fn getElementFacesArray obj selectedFaces =
(
	local numfaces = polyOp.getNumFaces obj
	local polyOp_getElementsUsingFace = polyOp.getElementsUsingFace
	
	for f = 1 to numFaces where selectedFaces[f] do
	(
		local elementFaces = polyOp_getElementsUsingFace obj f
		selectedFaces -= elementFaces
		append elementFacesArray elementFaces
	)
)

totalOverlappedFacesArray = #()
elementFacesArray = #()
elementEdgesArray = #()
edgeToVerts = #()
vertToVertPosition = #()

with undo off
(
	with redraw off
	(
		max create mode
		
		selectedObj = selection as array
		
		if (selectedObj.count == 1) and (classOf selectedObj[1].baseObject == Editable_Poly)  do
		(
			mainObj = selectedObj[1]
			
			local unwrapMod =  mainObj.modifiers[mainObj.modifiers.count]
			local selectedFaces = unwrapMod.getSelectedFaces()
			
			if (hasUVWUnwrapModifier mainObj) then
			(
				
				obj = copy mainObj
				ChannelInfo.CopyChannel obj 3 1
				ChannelInfo.PasteChannel obj 1 1
				ResetXForm obj
				convertToMesh obj
				convertToPoly obj
				
				start = timeStamp()
				
				numFaces = polyOp.getNumFaces obj
				
				/* --------------------
				--Pre-Fetch values
				-------------------- */
				
				-- Get Element Faces in an Array
				local numfaces = polyOp.getNumFaces obj
				local polyOp_getElementsUsingFace = polyOp.getElementsUsingFace
				
				for f = 1 to numFaces where selectedFaces[f] do
				(
					local elementFaces = polyOp_getElementsUsingFace obj f
					selectedFaces -= elementFaces
					append elementFacesArray elementFaces
				)
				format "Element faces array: %\n" elementFacesArray
				delete obj
				
				
				local unwrapModMain =  mainObj.modifiers[mainObj.modifiers.count]
				x = 0
				y = 0
				width = 0
				height = 0
				areaUVW = 0
				areaGeom = 0
				
				local minMaxData = #()
				
				minMaxData = for i = 1 to elementFacesArray.count collect
				(
					unwrapModMain.getArea elementFacesArray[i] &x &y &width &height &areaUVW &areaGeom
					#(x, y, width, height)
				)
				format "\nMinMax Data: %\n" minMaxData
				
				
				local overlappedUVShellIdxArray = #()
				local breakLoop = false
				local counter = 0
				local debugCounter = 0
				
				for i = 1 to minMaxData.count do
				(
					x1 = minMaxData[i][1]
					y1 = minMaxData[i][2]
					width1 = minMaxData[i][3]
					height1 = minMaxData[i][4]
					right1 = x1 + width1
					bottom1 = y1 + height1
					
					for j = i + 1 to minMaxData.count do
					(
						x2 = minMaxData[j][1]
						y2 = minMaxData[j][2]
						width2 = minMaxData[j][3]
						height2 = minMaxData[j][4]
						right2 = x2 + width2
						bottom2 = y2 + height2
						
						
						-- Overlap condition
						if ((right1 > x2) and (x1 < right2) and (bottom1 > y2) and (y1 < bottom2)) do
						(
							if (overlappedUVShellIdxArray.count == 0) then
							(
								debugCounter += 1
								append overlappedUVShellIdxArray #{i,j}
							)
							else
							(
								breakLoop = false
								counter = 1
								
								for data in overlappedUVShellIdxArray where breakLoop == false do
								(
									if (data[i] == 0 and data[j] == 0 and counter >= overlappedUVShellIdxArray.count) then
									(
										append overlappedUVShellIdxArray #{i,j}
										breakLoop = true
									)
									else if (data[i] == 1 and data[j] == 0) then
									(
										data[j] = 1
										breakLoop = true
									)
									else if (data[i] == 0 and data[j] == 1) then
									(
										data[i] = 1
										breakLoop = true
									)
									else if (data[i] == 1 and data[j] == 1) then
									(
										breakLoop = true
									)
									counter += 1
								)
							)
						)
					)
				)
				format "overlappedUVShellIdxArray: %\n" overlappedUVShellIdxArray
				
				
				/* --------------------
				-- Replace overlappedUVShellIdxArray with values from elementFacesArray
				-------------------- */
				
				-- Collect the array in overlappedUVShellArray
				overlappedUVShellArray = for overlappedUVShellIdx in overlappedUVShellIdxArray collect
				(
					local newSet = #{}
					for idx in overlappedUVShellIdx do newSet += elementFacesArray[idx]
					newSet
				)

				/* --------------------
				-- Assign groups for overlapped faces by looping overlappedUVShellArray
				-------------------- */
				
				-- Choose SubObjectLevel 3
				unwrapMod.setTVSubObjectMode 3
				
				-- Deselect all the faces
				unwrapMod.selectFaces #{}
				
				-- Looping overlappedUVShellArray 
				for i = 1 to overlappedUVShellArray.count do
				(
					-- Store overlappedUVShellArray[i] to tempVariable currFaceSelection
					local currFaceSelection = overlappedUVShellArray[i]
					
					-- Select faces in currFaceSelection
					unwrapMod.selectFaces currFaceSelection
					
					-- Create group for the current selection
					unwrapMod.GroupCreateBySelection()
					
					-- Deselect all the selected faces as it will overlap with the next iteration
					unwrapMod.selectFaces #{}
				)
			
				end = timeStamp()
				format "\nProcessing took % seconds\n" ((end - start) / 1000.0)
			)
		)
	)
)
max modify mode
