-- Skirt script is used to extrude the edges by -1.0 of a terrain/ground/road LODs and push them +1.0 in value.
-- As a result it will not create a gap resulting in light leakage and other weird artefacts.
-- We assign smoothing group values to greater than 20 as it's not used often and is very handy to select them when making changes to the existing entities.

(
	struct Skirt
	(
		-- Store the selectedEdges
		selectedEdges = #{},
		-- Store the selectedFaces
		selectedFaces = #{},
		
		-- Check if the object is of type editable poly
		fn IsValidObject obj =
		(
			return (classOf obj == Editable_Poly)
		),
		
		-- Check if the subobject level is Edge (subObjectLevel == 2) or Border (subObjectLevel == 3)
		fn IsValidSubObjectLevel obj =
		(
			return ((subObjectLevel == 2 or subObjectLevel == 3))
		),
		
		-- Get edges from selection
		fn GetSelectedEdges obj = 
		(
			return (selectedEdges = polyOp.getEdgeSelection obj)
		),
		
		-- Get faces from selection
		fn GetSelectedFaces obj =
		(
			return (selectedFaces = polyop.getFaceSelection obj)
		),
		
		-- Get Face smoothing group
		fn GetFaceSmoothingGroup obj faceIndex =
		(
			polyop.getFaceSmoothGroup obj faceIndex
		),
		
		-- Get SmoothingGroup for a face. It returns the result in bits
		fn SetFaceSmoothingGroup obj faceIndex currSmoothingGroupInBit addExistingBool = 
		(
			polyOp.setFaceSmoothGroup obj faceIndex currSmoothingGroupInBit add:addExistingBool
		),
		
		-- Add skirt function
		fn AddSkirt obj =
		(
			-- Setting Extrude values
			obj.edgeExtrudeHeight = -1
			obj.edgeExtrudeWidth = 0

			-- Extrude the edges
			obj.buttonOp #Extrude
			
			-- Add push modifier and update push value to 1
			modPanel.addModToSelection (push push_value:1)
			
			-- Collapse Stack
			collapseStack obj
			
			-- Change the subObjectLevel to 2 (Edge)
			subObjectLevel = 2
			
			-- Convert Edge to Face selection
			obj.ConvertSelection #Edge #Face
			
			-- Change the subObjectLevel to 4 (Face)
			subObjectLevel = 4
		),
		
		-- Autosmooth the selected faces based on the threshold value
		fn AutoSmoothFaceGroup obj threshold =
		(
			obj.autoSmoothThreshold = threshold
			polyop.autoSmooth obj
			
		),
		
		-- Offsets the smoothing group by 
		fn OffsetSmoothingGroup obj = 
		(
			-- Get face selection
			GetSelectedFaces obj
			
			-- Loop all the selectedFaces
			for faceIndex in selectedFaces do
			(
				-- Initializing currSmoothingGroupInBit
				local currSmoothingGroupInBit = -1
				
				-- Get smoothing group
				currSmoothingGroupInBit = GetFaceSmoothingGroup obj faceIndex
				
				-- Offsetting the smoothing group by 20
				if currSmoothingGroupInBit > -1 do
				(
					-- As the getFaceSmoothGroup won't give int, using this calculation to get int
					local currSmoothingGroupInt = (log(currSmoothingGroupInBit)/log(2) + 1)

					-- Offset to 20
					currSmoothingGroupInt += 20
					
					-- If the currSmoothingGroupInt >= 32 then we are ignoring it by taking only <= 32 into account.
					if(currSmoothingGroupInt <= 32) then
					(
						-- Converting smoothing group which is in int to bits (max compatible)
						currSmoothingGroupInBit = 2^(currSmoothingGroupInt-1)
						
						-- Set the face of the smoothing group
						SetFaceSmoothingGroup obj faceIndex currSmoothingGroupInBit false
					)
				)
			)
		)
	)

	with undo off, redraw off
	(
		-- Get the selected objects as array
		local selectedObjects = selection as array
		
		-- Enter if atleast one of the objects is selected
		if (selectedObjects.count == 1) do
		(
			-- Get the first selection
			local obj = selectedObjects[1]
			
			-- Create an instance of the Skirt struct
			local skirtInstance = Skirt()
			
			-- Condition to check if the object is of type Editable_Poly
			if (skirtInstance.IsValidObject obj) do
			(
				-- Condition to check if the edge or border is selected and more than one edges are selected
				if ((skirtInstance.IsValidSubObjectLevel obj) and ((skirtInstance.GetSelectedEdges obj).numberset > 0)) then
				(
				
					-- Add skirt
					skirtInstance.AddSkirt obj
					
					-- Add smoothing group and offset it
					local threshold = 30
					skirtInstance.AutoSmoothFaceGroup obj threshold
					
					-- Offset the smoothing groups
					skirtInstance.OffsetSmoothingGroup obj
				)
				else
				(
					-- Display messageBox when no edges are selected.
					messageBox "Select one or more edges to process"
				)
			)
		)
	)
)
