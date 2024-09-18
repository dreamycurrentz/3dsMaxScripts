-- Try catch exception to have only one instance of rollout at a time
try (DestroyDialog rol_randomiser) catch()

-- Rollout
rollout rol_randomiser "Randomiser Tools" width:120 height:520
(
	-- UI
	label lbl_title "Randomiser Tools" pos:[16,8] width:88 height:16

	button btn_deselect "Deselect" pos:[8,32] width:56 height:16
	spinner spn_deselect "" pos:[73,32] width:40 height:16 range:[0,99.9,35]
	
	GroupBox grp_pos "Position" pos:[8,56] width:104 height:120
	button btn_pos_all "Random All" pos:[16,80] width:88 height:16
	button btn_pos_x "X" pos:[16,104] width:32 height:16
	button btn_pos_y "Y" pos:[16,128] width:32 height:16
	button btn_pos_z "Z" pos:[16,152] width:32 height:16
	spinner spn_pos_x "" pos:[56,104] width:48 height:16 range:[0,999.9,10]
	spinner spn_pos_y "" pos:[56,128] width:48 height:16 range:[0,999.9,10]
	spinner spn_pos_z "" pos:[56,152] width:48 height:16 range:[0,999.9,10]
	
	GroupBox grp_rot "Rotation" pos:[8,184] width:104 height:120
	button btn_rot_all "Random All" pos:[17,208] width:88 height:16
	button btn_rot_x "X" pos:[16,232] width:32 height:16
	button btn_rot_y "Y" pos:[16,256] width:32 height:16
	button btn_rot_z "Z" pos:[16,280] width:32 height:16
	spinner spn_rot_x "" pos:[56,232] width:48 height:16 range:[0,180,180]
	spinner spn_rot_y "" pos:[56,256] width:48 height:16 range:[0,180,180]
	spinner spn_rot_z "" pos:[56,280] width:48 height:16 range:[0,180,180]
	
	GroupBox grp_scale "Scale" pos:[8,312] width:104 height:144
	button btn_scale_all "Random All" pos:[16,336] width:88 height:16
	button btn_scale_uniform "Random Uniform" pos:[16,360] width:88 height:16
	button btn_scale_x "X" pos:[16,384] width:32 height:16
	button btn_scale_y "Y" pos:[16,408] width:32 height:16
	button btn_scale_z "Z" pos:[16,432] width:32 height:16
	spinner spn_scale_x "" pos:[56,384] width:48 height:16 range:[1,20,1.5]
	spinner spn_scale_y "" pos:[56,408] width:48 height:16 range:[1,20,1.5]
	spinner spn_scale_z "" pos:[56,432] width:48 height:16 range:[1,20,1.5]
	
	GroupBox grp_colour "Colour" pos:[9,464] width:104 height:48
	button btn_colour_full "Full" pos:[17,488] width:32 height:16
	button btn_colour_grey "Grey" pos:[65,488] width:32 height:16
	
	
-- 	Functions
	
-- 	Randomly deselects the selected objects based on probability
--  Higher the prob value more elements gets deselected, lower the prob less gets deselected
	fn rand_deselect prob = 
	(
		local newselection = #()
		
		for i in (selection as array) do
		(
			if (random 0.0 100.0) >= prob then
			(
				append newselection i
			)
		)
		select newselection
	)
	
-- 	Move objects position by +/- amount on x, y and z
	fn rand_pos obj x y z =
	(
		obj.pos += [random -x x, random -y y, random -z z]
	)
	
-- 	Rotate objects by +/- amount on x, y and z
	fn rand_rot obj x y z =
	(
		obj.rotation.x_rotation += random -x x
		obj.rotation.y_rotation += random -y y
		obj.rotation.z_rotation += random -z z
	)
	
-- 	Scale objects by +/- amount of x, y and z
	fn rand_scale obj x y z uniform = 
	(
		fScale_x = 1.0
		fScale_y = 1.0
		fScale_z = 1.0
		
		fScale_x = random 1.0 x
		if (random 0 1) == 0 then (fScale_x = 1 / fScale_x)
		fScale_y = random 1.0 y
		if (random 0 1) == 0 then (fScale_y = 1 / fScale_y)
		fScale_z = random 1.0 z
		if (random 0 1) == 0 then (fScale_z = 1 / fScale_z)
		
-- 		If uniform then make all equal to x value
		if uniform == true then
		(
			fScale_y = fScale_x
			fScale_z = fScale_x
		)
		
		obj.scale *= [fScale_x, fScale_y, fScale_z]
	)
	
-- 	Generate random colour and assign to obj as wire colour
	fn rand_colour obj grey = 
	(
		r = random 0 255
		g = random 0 255
		b = random 0 255
		
		if grey == true then 
		(
			g = r
			b = r
		)
		
		obj.wirecolor = [r,g,b]
	)
	
	
-- 	Events
	
-- 	Deselect button
	on btn_deselect pressed do
	(
		rand_deselect spn_deselect.value
	)
	
-- 	Position buttons
	on btn_pos_all pressed do
	(
		for i in (selection as array) do
		(
			rand_pos i spn_pos_x.value spn_pos_y.value spn_pos_z.value
		)
	)
	
	on btn_pos_x pressed do
	(
		for i in (selection as array) do
		(
			rand_pos i spn_pos_x.value 0 0
		)
	)
	
	on btn_pos_y pressed do
	(
		for i in (selection as array) do
		(
			rand_pos i 0 spn_pos_y.value 0
		)
	)
	
	on btn_pos_z pressed do
	(
		for i in (selection as array) do
		(
			rand_pos i 0 0 spn_pos_z.value
		)
	)
	
-- 	Rotation buttons
	on btn_rot_all pressed do
	(
		for i in (selection as array) do
		(
			rand_rot i spn_rot_x.value spn_rot_y.value spn_rot_z.value
		)
	)
	
	on btn_rot_x pressed do
	(
		for i in (selection as array) do
		(
			rand_rot i spn_rot_x.value 0 0
		)
	)
	
	on btn_rot_y pressed do
	(
		for i in (selection as array) do
		(
			rand_rot i 0 spn_rot_y.value 0
		)
	)
	
	on btn_rot_z pressed do
	(
		for i in (selection as array) do
		(
			rand_rot i 0 0 spn_rot_z.value
		)
	)
	
-- 	Scale buttons
	on btn_scale_all pressed do
	(
		for i in (selection as array) do
		(
			rand_scale i spn_scale_x.value spn_scale_y.value spn_scale_z.value false
		)
	)
	
	on btn_scale_uniform pressed do
	(
		for i in (selection as array) do
		(
			rand_scale i spn_scale_x.value 1 1 true
		)
	)
	
	on btn_scale_x pressed do
	(
		for i in (selection as array) do
		(
			rand_scale i spn_scale_x.value 1 1 false
		)
	)
	
	on btn_scale_y pressed do
	(
		for i in (selection as array) do
		(
			rand_scale i 1 spn_scale_y.value 1 false
		)
	)
	
	on btn_scale_z pressed do
	(
		for i in (selection as array) do
		(
			rand_scale i 1 1 spn_scale_z.value false
		)
	)
	
-- 	Colour buttons
	on btn_colour_full pressed do
	(
		for i in (selection as array) do
		(
			rand_colour i false
		)
	)
-- 	
	on btn_colour_grey pressed do
	(
		for i in (selection as array) do
		(
			rand_colour i true
		)
	)
)

-- Create rollout
CreateDialog rol_randomiser