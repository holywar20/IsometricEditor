extends Panel

var faceData = null

func drawAllPolygons( newFaceData ):
	faceData = newFaceData 
	update()

func _draw():
	draw_colored_polygon ( 
		faceData[PolygonPanel.DRAWING_FACES.LEFT].points , 
		faceData[PolygonPanel.DRAWING_FACES.LEFT].shading , 
		faceData[PolygonPanel.DRAWING_FACES.LEFT].uvs , 
		load( faceData[PolygonPanel.DRAWING_FACES.LEFT].texturePath ) 
	)

	draw_colored_polygon ( 
		faceData[PolygonPanel.DRAWING_FACES.RIGHT].points , 
		faceData[PolygonPanel.DRAWING_FACES.RIGHT].shading , 
		faceData[PolygonPanel.DRAWING_FACES.RIGHT].uvs , 
		load( faceData[PolygonPanel.DRAWING_FACES.RIGHT].texturePath ) 
	)

	draw_colored_polygon ( 
		faceData[PolygonPanel.DRAWING_FACES.TOP].points , 
		faceData[PolygonPanel.DRAWING_FACES.TOP].shading , 
		faceData[PolygonPanel.DRAWING_FACES.TOP].uvs , 
		load( faceData[PolygonPanel.DRAWING_FACES.TOP].texturePath ) 
	)
	#
	#for key in faceData:
	#	draw_colored_polygon( faceData[key].points , faceData[key].shading , faceData[key].uvs , load( faceData[key].texturePath ) )
