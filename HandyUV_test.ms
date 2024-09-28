try(DestroyDialog handyUV)catch()


fn offsetUV offsetVal =
(
	if (classOf (modPanel.getCurrentObject()) == Unwrap_UVW) then
	(
		unwrapMod = modPanel.getCurrentObject()
		unwrapMod.getSelectedFaces()
		unwrapMod.moveSelected offsetVal
	)
	else
	(
		messageBox "Add UnwrapUVW modifier"
	)
)

fn applyHasPuddles =
(
	local obj = $
	
	if(classOf (modPanel.getCurrentObject()) == Unwrap_UVW) do
	(
		unwrapMod = modPanel.getCurrentObject()
		local selectedFaces = unwrapMod.getSelectedFaces()
		
		multiMat = MultiMaterial numsubs:2
		local currMat = obj.material
		local hasPuddlesMat = copy currMat
		
		multiMat[1] = currMat
		multiMat[2] = hasPuddlesMat
		
		polyop_setFaceMatID = polyop.setFaceMatID
		for f in selectedFaces do polyop_setFaceMatID obj f 2
		
		obj.material = multiMat
	)
)


Rollout handyUV "Handy UV"
(
	label lab1 "Offset UV" align:#left
	button btn_offset_U "Offset U" across: 2
	button btn_offset_V "Offset V"
	
	button btn_applyHasPuddles "Apply Has Puddles"
	
-- 	button up "Up"
-- 	button left "Left" align:#left across: 2
-- 	button right "Right" align:#right
-- 	button down "Down"
	
	on btn_offset_U pressed do
	(
		offsetUV [1,0,0]
	)
	
	on btn_offset_U rightclick do
	(
		offsetUV [-1,0,0]
	)
	
	on btn_offset_V pressed do
	(
		offsetUV [0,1,0]
	)
	
	on btn_offset_V rightclick do
	(
		offsetUV [0,-1,0]
	)
	
	on btn_applyHasPuddles pressed do
	(
		applyHasPuddles()
	)
)

CreateDialog handyUV
