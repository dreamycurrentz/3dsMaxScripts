try (DestroyDialog MaterialToolbox) catch()

previewFilePath = "D:\Resources\Icons\\"

fn mtlLibrary objarr index =
(
	tmpLib = loadTempMaterialLibrary "C:\Users\akash\Documents\3ds Max 2021\materiallibraries\UsefulMaterials.mat"
	for obj in objarr do obj.material = tmpLib [index]
)

fn selSimilar selObj = 
(
	selectedObjects = #()
	if selObj.count != 1 then messageBox "Select only one obj"
	else
	(
		currentMaterial = selObj[1].material
		format "\nCurrentMaterial: %" currentMaterial.name
		
		for obj in objects do 
		(
			format "\nObj Mat: %" obj.name
			if (obj.material == currentMaterial) do
			(
				print "\nEntered"
				append selectedObjects obj
			)
		)
		select selectedObjects
	)
)

fn pickMaterial objArr picked =
(
	if objArr.count == 0 then messageBox "No object selected"
	else for obj in objArr do obj.material = picked.material
)

fn selUndefined selObj =
(
	for obj in objects where obj.material == undefined do selectmore obj
)

fn removeAllMateirals selObj = 
(
	selObj.material = undefined
)

rollout MaterialToolbox "Material Tools" width: 340
(
	button btn_checkerPatternMtl "" iconName: (previewFilePath + "checker_default_mat.jpg") iconsize:[140, 140] width: 150 height: 150
	button btn_similar "Select Similar" tooltip:"Select objects with same material" width:150 height: 50 across:2
	button btn_undefined "Select Undefined" tootip:"Select objects with no material" width:150 height: 50
-- 	button pkbtn_pickMaterial "Pick Material" tooltip: "Pick any object to copy materials from" width:150 height: 50 across:2
	button btn_removeAllMaterials "Remove All Materials" tooltip: "Remove all the materials from the selected objects" width:150 height: 50
	
	on btn_checkerPatternMtl pressed do mtlLibrary (selection as array) 1
	on btn_similar pressed do selSimilar (selection as array)
	on btn_undefined pressed do selUndefined (selection as array)
	on pkbtn_pickMaterial picked selObj do pickMaterial (selection as array) selObj
	on btn_removeAllMaterials pressed do removeAllMateirals (selection as array)
)

CreateDialog MaterialToolbox


