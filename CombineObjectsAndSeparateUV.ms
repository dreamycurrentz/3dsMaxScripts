-- This script is used to select multiple objects flatten UV and keep it in separate UV coordinates.

uvcoordNumX = 0

-- Get all the selected objects
for obj in selection as array do
(
	-- Get number of faces
	num_faces = polyop.getNumFaces obj
	max modify mode
	
	-- Add unwrap modifier
	unwrapMod = Unwrap_UVW()
	addModifier obj unwrapMod

	format "\nNum Faces: %" num_faces
	
	-- Select face mode in UV (3)
	unwrapMod.setTVSubObjectMode 3
	
	-- Select all the faces
	unwrapMod.selectFaces #{1..obj.faces.count}
	
	-- Flatten map the selected faces
	unwrapMod.flattenMapNoParams()

	-- Select all the faces
	unwrapMod.setTVSubObjectMode 3
	unwrapMod.selectFaces #{1..obj.faces.count}
	
	-- Downscale them to 50% of their original size since it will be difficult to select with the neighbouring UV coordinates
	unwrapMod.scaleSelectedXY -0.5 -0.5 [0.5,0.5,0]
	
	-- We are placing the UVs starting from (0, -1, 0) UV coordinate
	coordPos = point3 uvcoordNumX -1 0
	format "\n CoordPos: %" coordPos
	
	-- Move the selected faces to the respective position
	unwrapMod.moveSelected coordPos
	
	-- Increment the X coordinate by 1 for the next object
	uvcoordNumX += 1
	
	-- Collapse Stack object at the end
	collapseStack obj
)