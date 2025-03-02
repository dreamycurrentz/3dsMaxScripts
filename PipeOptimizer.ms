struct sPipeOptimizer
(
	
	fn IsValidObject obj =
	(
		return (classOf obj == Editable_Poly)
	),
	
	fn OptimizePipes =
	(
		local obj = (selection as array)[1]
		local cylinderEndsBool = true
		
		if (IsValidObject obj) do
		(
			-- Get connected edges
			PolyToolsSelect.Loop cylinderEndsBool
			
			-- Get selected edges
			local totalSelectedEdgesBArr = polyop.getEdgeSelection obj
			format "Selected edges: %\n" selectedEdgesBArr
			
			local connectedEdgesArr = #()
			local visitedEdges = #{}
			
			-- Traverse all the edges and store the connected edges in an array
			for edge in totalSelectedEdgesBArr do
			(
				if visitedEdges[edge] then continue
					
				polyop.setEdgeSelection obj #{edge}
				PolyToolsSelect.Loop cylinderEndsBool
				local currentSelectedEdgesBArr = polyop.getEdgeSelection obj
				visitedEdges += currentSelectedEdgesBArr
				appendIfUnique connectedEdgesArr currentSelectedEdgesBArr
			)
			polyop.setEdgeSelection obj totalSelectedEdgesBArr
			format "connectedEdgesArr: %\n" connectedEdgesArr
			
			local totalPos = [0,0,0]
			
			-- Get the center of point of the connected edges
			for idx = 1 to connectedEdgesArr.count do
			(
				totalPos = [0,0,0]
				
				local currentEdgeLoopVertsBArr = polyop.getVertsUsingEdge obj connectedEdgesArr[idx]
				format "currentEdgeLoopVertsBArr: %\n" currentEdgeLoopVertsBArr

				local vertPositionArr = polyop.getVerts obj currentEdgeLoopVertsBArr
				format "vertPositionArr: %\n" vertPositionArr
				
				for idx = 1 to vertPositionArr.count do
				(
					totalPos += vertPositionArr[idx]
				)
				
				local avgPos = totalPos / (vertPositionArr.count)
				
				local pt = Point size: 5 pos: avgPos
			)

			
			-- Connect the points
			-- Render in viewport - final tweaks
		)
	)
)

global sPipeOptimizerInstance = sPipeOptimizer()
sPipeOptimizerInstance.OptimizePipes()
