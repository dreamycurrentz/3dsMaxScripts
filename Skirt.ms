-- Skirt script is used to extrude the edges of a terrain/ground LODs and push them 1.0 in vaule
-- As a result it will not create a gap resulting in light leakage and other weird artefacts.
-- We assign smoothing group values to greater than 20 as it's not used often and is very handy to select them when making changes to the existing entities.


fn addSkirt =
(
-- 	Only process if the subobject level is in Edge mode (2) or Border mode (3).
	if subObjectLevel == 2 or subObjectLevel == 3 then
	(
		
		local obj = selection[1]
		
		-- Get the current selected edges
		local currEdgeSelection = polyOp.getEdgeSelection obj
		
		-- Process only if there are selected edges.
		if currEdgeSelection.numberSet > 0 then
		(
			-- Setting Extrude values
			obj.edgeExtrudeHeight = -1
			obj.edgeExtrudeWidth = 0
			obj.buttonOp #Extrude
			
			-- Push value to 1
			modPanel.addModToSelection(push push_value:1)
			collapseStack obj
			
			-- Select edge mode (2)
			subObjectLevel = 2
			
			-- Convert edge selection to face so that we can assign the smoothing group
			obj.ConvertSelection #Edge #Face
			subObjectLevel = 4
		)
		else
		(
			messagebox "Select edges first."
		)
	)
	else
	(
		messageBox "Go into Edge or Border mode and select 1 or more edges"
	)
)

fn addSmoothingGroup =
(
	local obj = selection[1]
	
	-- Autosmooth the selected faces with threshold set to 30
	obj.autoSmoothThreshold = 30
	polyop.autoSmooth obj
	
	-- Get face selection
	selectedFaces = polyop.getFaceSelection obj
	for faceIndex in selectedFaces do
	(
		print "Face index: "; print faceIndex
		local currSmoothingGroup = -1
		
		-- Get smoothing group
		currSmoothingGroup = polyop.getFaceSmoothGroup obj faceIndex
		print "Current smoothing group: "; print currSmoothingGroup
					
		-- Offsetting the smoothing group by 20
		if currSmoothingGroup > -1 do
		(
			-- As the getFaceSmoothGroup won't give int, using this calculation to get in int
			currSmoothingGroupInt = log(currSmoothingGroup)/log(2) + 1
			print "Current smoothing group: "; print currSmoothingGroupInt
						
			-- Offset to 20
			currSmoothingGroupInt += 20
						
			if(currSmoothingGroupInt > 32) then
			(
				messageBox "Error with the smoothing groups"
			)
			else
			(
				--Converting smoothing group which is in int number to max readable format
				currSmoothingGroup = 2^(currSmoothingGroupInt-1)
				polyOp.setFaceSmoothGroup obj faceIndex currSmoothingGroup add:false
			)
		)
	)
)

-- Main code starts here
if selection.count == 1 and isKindOf selection[1] Editable_Poly then
(
-- 	Add skirt
	addSkirt()
	
-- 	Assign smoothing group to 20 and above as it will be easier to delete later.
	addSmoothingGroup()
)
else if selection.count == 0 then
(
	messageBox "No objects selected"
)
else
(
	messageBox "More than one objects selected"
)