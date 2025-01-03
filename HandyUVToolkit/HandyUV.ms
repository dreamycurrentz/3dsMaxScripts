try (DestroyDialog handyUVRollout) catch()

fileIn "C:\\Users\\akash\\Desktop\\MaxScriptsPractice\\OptimizeCodeTry_01\\OptimizeCodeTry_02_07.ms"

Rollout handyUVRollout "Handy UV"
(
	group "Offset UV controls"
	(
		button btn_offset_U "Offset U" width:85 align:#left across:2 tooltip:"LeftClick: Offsets the selected UVs along +U axis\nRightClick: Offsets the selected UVs along -U axis"
		spinner spn_offset_U "" width:50 range:[0,15,1] align:#right offset:[0,2.5]
		
		button btn_offset_V "Offset V" width:85 align:#left across:2 tooltip:"LeftClick: Offsets the selected UVs along +V axis\nRightClick: Offsets the selected UVs along -V axis"
		spinner spn_offset_V "" width:50 range:[0,15,1] align:#right offset:[0,2.5]
	)
	
	group "Overlapped UVs"
	(
		radioButtons rbOptions "Calculation methods:" labels:#("Bounds Calculation", "Edge Calculation") default:1 align:#left offset:[0,2.5]
		button btn_selectOverlapped_UV "Select Overlapped UVs" width:150 align:#left
		
		button btn_offsetOverlapped_UV "Offset UVs" width:85 height:40 align:#left offset:[0,5]
		spinner spn_offset_U1 "U" width:50 range:[-15,15,1] align:#right offset:[0,-43]
		spinner spn_offset_V1 "V" width:50 range:[-15,15,1] align:#right
	)
	
	--Used for debug
	on handyUVRollout open do
	(
-- 		btn_selectOverlapped_UV.width = handyUVRollout.width - 40
		
-- 		local pos = btn_offset_U.pos
--         local width = btn_offset_U.width 
--         local height = btn_offset_U.height
--         
--         format "Button Position: %\n" pos
--         format "Button Width: %\n" width
--         format "Button Height: %\n" height
	)
	
	on btn_offset_U pressed do
	(
		overlappedUVInstance.offsetUV [spn_offset_U.value, 0, 0]
	)
	
	on btn_offset_U rightclick do
	(
		overlappedUVInstance.offsetUV [-spn_offset_U.value, 0, 0]
	)
	
	on btn_offset_V pressed do
	(
		overlappedUVInstance.offsetUV [0, spn_offset_V.value, 0]
	)
	
	on btn_offset_V rightclick do
	(
		overlappedUVInstance.offsetUV [0, -spn_offset_V.value, 0]
	)
	
	on btn_selectOverlapped_UV pressed do
	(
		overlappedUVInstance.selectOverlappedUV rbOptions.state
	)
)

CreateDialog handyUVRollout height: 250 width: 175
overlappedUVInstance = OverlappedUV()
