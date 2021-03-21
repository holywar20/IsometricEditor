extends Panel

var faceData = null

func drawAllPolygons( newFaceData ):
	faceData = newFaceData 
	update()

func _draw():
	for key in faceData:
		draw_colored_polygon( faceData[key].points , faceData[key].shading , faceData[key].uvs , load(faceData[key].texturePath ) )
