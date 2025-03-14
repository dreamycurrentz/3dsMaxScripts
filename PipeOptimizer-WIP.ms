struct sPipeOptimizer
(
	_radiusVal = 0,
	
	fn IsValidObject obj =
	(
		return (classOf obj == Editable_Poly)
	),
	
	fn CreateKnotFromVertices obj vertexBArr pointPosArr =
	(
		local totalPos = [0,0,0]
		local vertPositionArr = polyop.getVerts obj vertexBArr
		
		for idx = 1 to vertPositionArr.count do
		(
			totalPos += vertPositionArr[idx]
		)
		
		local avgPos = totalPos / (vertPositionArr.count)
		
		append pointPosArr avgPos
		
		format "pointPosArr: %\n" pointPosArr
		format "avgPos: %\n" avgPos
		
		local pt = Point size: 5 pos: avgPos
		
		distanceVal = distance vertPositionArr[1] avgPos
		format "distanceVal: %\n" distanceVal
		format "radiusVal: %\n" radiusVal
		if (distanceVal > this._radiusVal) do 
		(
			this._radiusVal = distanceVal
		)
		format "vertPositionArr: %\n" vertPositionArr
		format "radiusVal: %\n" radiusVal

	),
	
	fn ConnectPoints pointPosArr radiusVal =
	(
		local ss = SplineShape pos:[0,0,0]
		addNewSpline ss
			
		if (pointPosArr.count > 1) do
		(
			for i = 1 to pointPosArr.count do
			(
				addKnot ss 1 #corner #line pointPosArr[i]
			)
		)
			
		-- Render in viewport - final tweaks
		ss.render_displayRenderMesh = true
		ss.render_sides = 5
		ss.render_thickness = (this._radiusVal * 2)
		updateShape ss
	),
	
	fn AutomaticEdgeSelection obj = 
	(
		local selectedVerticesBArr = polyop.getVertSelection obj
		
		if (selectedVerticesBArr.numberSet > 0 and getSelectionLevel $ == #vertex) then
		(

			local totalVertices = obj.numverts
			local currentVertexSelectionBArr = #{}
			local previousVertexSelectionBArr = #{}
			local pointPosArr = #()
			local counter = 1
			local extraRun = true
			local radiusVal = 0
			
			
			while ((polyop.getVertSelection obj).numberSet < totalVertices) or (extraRun == true) do
			(
				selectedVerticesBArr = polyop.getVertSelection obj
	
				currentVertexSelectionBArr = selectedVerticesBArr - previousVertexSelectionBArr
				previousVertexSelectionBArr = selectedVerticesBArr
				format "selectedVerticesBArr: %\n" selectedVerticesBArr
				format "currentVertexSelectionBArr: %\n" currentVertexSelectionBArr
				
				CreateKnotFromVertices obj currentVertexSelectionBArr pointPosArr
				
				if ((polyop.getVertSelection obj).numberSet >= totalVertices) do extraRun = false
				
				format "Counter: %\n\n" counter
				counter += 1
				
				obj.GrowSelection selLevel: #vertex
			)
			format "RadiusValBeforeConnectPoints: %\n" this._radiusVal
			ConnectPoints pointPosArr this._radiusVal
		)
		else
		(
			messagebox "Select a vertex loop"
		)
	),
	
	fn OptimizePipes =
	(
		local obj = (selection as array)[1]
		
		
		if (IsValidObject obj) do
		(
			-- Two methods
			-- 1. Manual edge selection
			-- 2. Automatic edge selection
			

			AutomaticEdgeSelection obj
			
			

		)
	)
)

global sPipeOptimizerInstance = sPipeOptimizer()
sPipeOptimizerInstance.OptimizePipes()
