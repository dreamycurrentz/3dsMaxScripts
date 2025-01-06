try (DestroyDialog handyUVRollout) catch()

fileIn "./OverlappedUV.ms"

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
	)
	
	-- Offset U button +ve axis
	on btn_offset_U pressed do
	(
		overlappedUVInstance.offsetUV [spn_offset_U.value, 0, 0]
	)
	
	-- Offset U button -ve axis
	on btn_offset_U rightclick do
	(
		overlappedUVInstance.offsetUV [-spn_offset_U.value, 0, 0]
	)

	-- Offset V button +ve axis
	on btn_offset_V pressed do
	(
		overlappedUVInstance.offsetUV [0, spn_offset_V.value, 0]
	)
	
	-- Offset V button -ve axis
	on btn_offset_V rightclick do
	(
		overlappedUVInstance.offsetUV [0, -spn_offset_V.value, 0]
	)
	
	-- Overlapped UVs selection button
	on btn_selectOverlapped_UV pressed do
	(
		-- Switch case to handle the radio buttons
		case rbOptions.state of
        (
			-- Use BoundingBox method to check for UV overlaps
            1: overlappedUVInstance.CheckUVOverlap (selection as array) rbOptions.state
			
			-- Use Edge-based method to check for UV overlaps
            2: overlappedUVInstance.CheckUVOverlap (selection as array) rbOptions.state
			
			-- Default case: Handle unexpected or unimplemented cases
			default: format "Unhandled case\n"
        )
	)
)

CreateDialog handyUVRollout height: 195 width: 175
