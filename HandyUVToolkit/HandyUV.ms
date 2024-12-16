try (DestroyDialog handyUV) catch()

fileIn "C:\\Users\\akash\\Desktop\\MaxScriptsPractice\\OptimizeCodeTry_01\\OptimizeCodeTry_02_05.ms"



Rollout handyUV "Handy UV"
(
	group "Offset UV controls"
	(
		button btn_offset_U "Offset U" across:2
		button btn_offset_V "Offset V"
	)
	
	group "Overlapped UVs"
	(
		button btn_selectOverlapped_UV "Select Overlapped UVs"
	)
	
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
	
	on btn_selectOverlapped_UV pressed do
	(
		overlappedUVInstance.CheckUVOverlap (selection as array)
	)
)

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

CreateDialog handyUV height: 250 width: 150
overlappedUVInstance = OverlappedUV()