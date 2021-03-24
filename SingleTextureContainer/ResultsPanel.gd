extends Panel

onready var zoomLabel = $Label

var faceData = null
var zoomedFaceData = {
	PolygonPanel.DRAWING_FACES.LEFT : {
		'points' : PoolVector2Array()
	},
	PolygonPanel.DRAWING_FACES.TOP : {
		'points' :  PoolVector2Array()
	},
	PolygonPanel.DRAWING_FACES.RIGHT: {
		'points' : PoolVector2Array()
	}
}
var zoomLevel = 1.0

func _ready():
	_calculateZoomLevel( 0.0 )

func drawAllPolygons( newFaceData ):
	_calculateZoomLevel( 0.0 )
	faceData = newFaceData 
	update()

func _draw():
	# Fudge the numbers by the zoom factor
	# Draw Left Polygon
	draw_colored_polygon ( 
		zoomedFaceData[PolygonPanel.DRAWING_FACES.LEFT].points, 
		faceData[PolygonPanel.DRAWING_FACES.LEFT].shading , 
		faceData[PolygonPanel.DRAWING_FACES.LEFT].uvs , 
		load( faceData[PolygonPanel.DRAWING_FACES.LEFT].texturePath ) 
	)

	# Draw Right Polygon
	draw_colored_polygon ( 
		zoomedFaceData[PolygonPanel.DRAWING_FACES.RIGHT].points , 
		faceData[PolygonPanel.DRAWING_FACES.RIGHT].shading , 
		faceData[PolygonPanel.DRAWING_FACES.RIGHT].uvs , 
		load( faceData[PolygonPanel.DRAWING_FACES.RIGHT].texturePath ) 
	)

	# Draw Left Polygon
	draw_colored_polygon ( 
		zoomedFaceData[PolygonPanel.DRAWING_FACES.TOP].points, 
		faceData[PolygonPanel.DRAWING_FACES.TOP].shading , 
		faceData[PolygonPanel.DRAWING_FACES.TOP].uvs , 
		load( faceData[PolygonPanel.DRAWING_FACES.TOP].texturePath ) 
	)
	#
	#for key in faceData:
	#	draw_colored_polygon( faceData[key].points , faceData[key].shading , faceData[key].uvs , load( faceData[key].texturePath ) )

func exportFinishedTexture():
	pass

func _calculateZoomLevel( zoomChange ):
	zoomLevel = zoomLevel + zoomChange
	
	if( zoomLevel != 1.0 ):
		for facingKey in faceData:
			for idx in range( 0 , faceData[facingKey].points.size() ):
				zoomedFaceData[facingKey].points[idx] = faceData[facingKey].points[idx] * zoomLevel
	else:
		for facingKey in faceData:
			zoomedFaceData[facingKey].points = faceData[facingKey].points

# Signals
func _on_ZoomPlus_pressed():
	_calculateZoomLevel( 0.1 )
	update()
	zoomLabel.set_text( zoomLevel * 100 + "%" )

func _on_ZoomMinus_pressed():
	_calculateZoomLevel( -0.1)
	update()
	zoomLabel.set_text( zoomLevel * 100 + "%" )
