extends Panel

enum DRAWING_FACES{
	LEFT , RIGHT , TOP
}

# Needs to be identical to ISO panel or it will break. Need to get around wacky handling of Godot and constant arrays
enum DIRECTION {
	LEFT , DOWN , RIGHT, UP
}

var fullFaceUvs = PoolVector2Array([
	Vector2(0, 0) ,  Vector2(1, 0) , Vector2(1, 1) , Vector2(0, 1)
])

var halfFaceUvs = PoolVector2Array([
	Vector2(0, 0.5), Vector2(1, 0.5), Vector2(1, 1) ,Vector2(0, 1)
])

var cornerFaceUvs = PoolVector2Array([
	
])

const DEFAULT_FACING_DATA = {
	DRAWING_FACES.LEFT : {
		"points" : [ Vector2(0,0) , Vector2(0,0) , Vector2(0,0) , Vector2(0,0)],
		"uvs" : [Vector2(0,0) , Vector2(0,0) , Vector2(0,0) , Vector2(0,0)],
		"shading" : Color( .9 , .9, .9, 1 ),
		"texturePath" : "res://Textures/checker.png"
	},
	DRAWING_FACES.RIGHT : {
		"points" : [ Vector2(0,0) , Vector2(0,0) , Vector2(0,0) , Vector2(0,0)],
		"uvs" : [ Vector2(0,0) , Vector2(0,0) , Vector2(0,0) , Vector2(0,0)],
		"shading" : Color( .8 , .8 , .8 , 1),
		"texturePath" : "res://Textures/checker.png"
	},
	DRAWING_FACES.TOP: {
		"points" : [ Vector2(0,0) , Vector2(0,0) , Vector2(0,0) , Vector2(0,0)],
		"uvs" : [ Vector2(0,0) , Vector2(0,0) , Vector2(0,0) , Vector2(0,0)],
		"shading" : Color( 1 , 1, 1, 1 ),
		"texturePath" : "res://Textures/checker.png"
	}
}

# Use full UVs for all top
var rampFaceUVs = {
	DIRECTION.LEFT : {
		DRAWING_FACES.RIGHT : PoolVector2Array([Vector2(0, 0) , Vector2(1, 1) , Vector2(1, 1) , Vector2(0, 1)]),
		DRAWING_FACES.LEFT : PoolVector2Array([Vector2(0, 0) , Vector2(1, 1) , Vector2(1, 1) , Vector2(0, 1)])
	},
	DIRECTION.RIGHT : {
		DRAWING_FACES.RIGHT : PoolVector2Array([Vector2(0, 0) , Vector2(1, 0), Vector2(1, 1) , Vector2(0, 1)]),
		DRAWING_FACES.LEFT : PoolVector2Array([Vector2(0, 0) , Vector2(1, 0) , Vector2(1, 1) , Vector2(0, 1)])
	}, 
	DIRECTION.DOWN : {
		DRAWING_FACES.RIGHT : PoolVector2Array( [Vector2(0, 0) , Vector2( 1, 0 ), Vector2( 1 , 1), Vector2(0 , 1) ] ),
		DRAWING_FACES.LEFT : PoolVector2Array( [Vector2(0, 0) , Vector2( 1, 0 ), Vector2( 1 , 1), Vector2(0 , 1) ] )
	},
	DIRECTION.UP : {
		DRAWING_FACES.RIGHT : PoolVector2Array([Vector2(0, 1) , Vector2(1, 0), Vector2(1, 1) , Vector2(0, 1)]),
		DRAWING_FACES.LEFT : PoolVector2Array([Vector2(0, 0) , Vector2(1, 0), Vector2(1, 1) , Vector2(0, 1)])
	}
}

var diamondInclineFaceUVs = {
	DIRECTION.LEFT : {
		DRAWING_FACES.RIGHT : PoolVector2Array([Vector2(0, 0) , Vector2(1, 1) , Vector2(1, 1) , Vector2(0, 1)]),
		DRAWING_FACES.LEFT : PoolVector2Array([Vector2(0, 0) , Vector2(1, 1) , Vector2(1, 1) , Vector2(0, 1)])
	},
	DIRECTION.RIGHT : {
		DRAWING_FACES.RIGHT : PoolVector2Array([Vector2(0, 0) , Vector2(1, 0), Vector2(1, 1) , Vector2(0, 1)]),
		DRAWING_FACES.LEFT : PoolVector2Array([Vector2(0, 0) , Vector2(1, 0) , Vector2(1, 1) , Vector2(0, 1)])
	}, 
	DIRECTION.DOWN : {
		DRAWING_FACES.RIGHT : PoolVector2Array( [Vector2(0, 0) , Vector2( 1, 0 ), Vector2( 1 , 1), Vector2(0 , 1) ] ),
		DRAWING_FACES.LEFT : PoolVector2Array( [Vector2(0, 0) , Vector2( 1, 0 ), Vector2( 1 , 1), Vector2(0 , 1) ] )
	},
	DIRECTION.UP : {
		DRAWING_FACES.RIGHT : PoolVector2Array([Vector2(0, 1) , Vector2(1, 0), Vector2(1, 1) , Vector2(0, 1)]),
		DRAWING_FACES.LEFT : PoolVector2Array([Vector2(0, 0) , Vector2(1, 0), Vector2(1, 1) , Vector2(0, 1)])
	}
}

var flatTopFaceUVs = {
	DIRECTION.LEFT : {
		DRAWING_FACES.RIGHT : PoolVector2Array([Vector2(0, 1) , Vector2(1, 0), Vector2(1, 1) , Vector2(0, 1)]),
		DRAWING_FACES.LEFT : PoolVector2Array([Vector2(0, 0) , Vector2(1, 0) , Vector2(1, 1) , Vector2(0, 1)])
	},
	DIRECTION.RIGHT : {
		DRAWING_FACES.RIGHT : PoolVector2Array([Vector2(0, 0) , Vector2(1, 0), Vector2(1, 1) , Vector2(0, 1)]),
		DRAWING_FACES.LEFT : PoolVector2Array([Vector2(0, 0) , Vector2(1, 0) , Vector2(1, 1) , Vector2(0, 1)])
	}, 
	DIRECTION.DOWN : {
		DRAWING_FACES.RIGHT : PoolVector2Array( [Vector2(0, 0) , Vector2( 1, 0 ), Vector2( 1 , 1), Vector2(0 , 1) ] ),
		DRAWING_FACES.LEFT : PoolVector2Array( [Vector2(0, 0) , Vector2( 1, 0 ), Vector2( 1 , 1), Vector2(0 , 1) ] )
	},
	DIRECTION.UP : {
		DRAWING_FACES.RIGHT : PoolVector2Array([Vector2(0, 0) , Vector2(1, 0), Vector2(1, 1) , Vector2(0, 1)]),
		DRAWING_FACES.LEFT : PoolVector2Array([Vector2(0, 0) , Vector2(1, 0), Vector2(1, 1) , Vector2(0, 1)])
	}
}

const DIR_VECTORS = {
	DIRECTION.LEFT : Vector2.LEFT,
	DIRECTION.DOWN : Vector2.DOWN, 
	DIRECTION.RIGHT : Vector2.RIGHT,
	DIRECTION.UP : Vector2.UP
}
const DIR_DISPLAY = {
	DIRECTION.LEFT : "Left" , 
	DIRECTION.RIGHT  : "Right",
	DIRECTION.UP : "Up",
	DIRECTION.DOWN : "Down"
}

# Panel Buttons
onready var zoomLabel = $Label
onready var resetButton = $ResetButton

# Passed from other things
var tileRadius : int = 72
var blockType : int = IsoPanel.BLOCK_TYPES.BOX
var direction : int = IsoPanel.DIRECTION.LEFT

# State Data
var faceData = null
var zoomedFaceData = {
	DRAWING_FACES.LEFT : {
		'points' : PoolVector2Array()
	},
	DRAWING_FACES.TOP : {
		'points' :  PoolVector2Array()
	},
	DRAWING_FACES.RIGHT: {
		'points' : PoolVector2Array()
	}
}
var zoomLevel = 1.0
var offset = Vector2( rect_size.x * 0.5 - float(tileRadius) , rect_size.y * 0.5 - float(tileRadius) )

func setupScene( newTileRadius, newBlockType , newDirection ):
	tileRadius = newTileRadius
	blockType = newBlockType
	direction = newDirection

func drawTextures():
	faceData = DEFAULT_FACING_DATA.duplicate( true ) 

	match blockType:
		IsoPanel.BLOCK_TYPES.NONE:
			faceData = DEFAULT_FACING_DATA.duplicate( true ) 
		IsoPanel.BLOCK_TYPES.BOX:
			generateLeftFace( 0 )
			generateRightFace( 0 )
			generateTopFace( 0 )
		IsoPanel.BLOCK_TYPES.EVEN_INCLINE:
			generateLeftFaceRamp( 0 , direction )
			generateRightFaceRamp( 0 , direction )
			generateTopFaceRamp( 0 , direction )
		IsoPanel.BLOCK_TYPES.DIAMOND_INCLINE:
			generateLeftCornerFace( 0 , direction )
			generateRightCornerFace( 0 , direction )
			generateTopCornerFace( 0 , direction )
		IsoPanel.BLOCK_TYPES.FLAT_TOP_CORNER:
			generateFlatTopCornerFace( 0 , direction )
			generateFlatTopLeftCornerFace( 0 , direction )
			generateFlatTopRightCornerFace(0 , direction )
		IsoPanel.BLOCK_TYPES.FLAT_BASE_CORNER:
			pass 
	
	drawAllPolygons( faceData )


func _ready():
	# Set zoom level if it uses a non-default level on load.
	pass

func drawAllPolygons( newFaceData , newZoomLevel = null ):
	# Set my primary face data
	faceData = newFaceData

	# Should also prevent people from setting a zoom of zero
	if( newZoomLevel ):
		zoomLevel = newZoomLevel

	# Make sure I got zoom data
	_calculateZoomLevel( zoomLevel )

	update()

func _draw():
	print(faceData)
	
	if( blockType == IsoPanel.BLOCK_TYPES.NONE ):
		return
	
	if( !faceData ):
		return

	if( zoomLevel == 1 ):
		resetButton.set_disabled( true )
		resetButton.set_self_modulate( Color( .3, .3 , .3 , 1) )
	else:
		resetButton.set_disabled( false )
		resetButton.set_self_modulate( Color( 1, 1 , 1 , 1) )

	# Fudge the numbers by the zoom factor
	
	# Draw Left Polygon
	# TODO - Build polygons here
	draw_colored_polygon ( 
		zoomedFaceData[DRAWING_FACES.LEFT].points, 
		faceData[DRAWING_FACES.LEFT].shading , 
		faceData[DRAWING_FACES.LEFT].uvs , 
		load( faceData[DRAWING_FACES.LEFT].texturePath ) 
	)

	# Draw Right Polygon
	# TODO - Build polygons here
	draw_colored_polygon ( 
		zoomedFaceData[DRAWING_FACES.RIGHT].points , 
		faceData[DRAWING_FACES.RIGHT].shading , 
		faceData[DRAWING_FACES.RIGHT].uvs , 
		load( faceData[DRAWING_FACES.RIGHT].texturePath ) 
	)

	# Draw Left Polygon
	# TODO - Build polygons here
	draw_colored_polygon ( 
		zoomedFaceData[DRAWING_FACES.TOP].points, 
		faceData[DRAWING_FACES.TOP].shading , 
		faceData[DRAWING_FACES.TOP].uvs , 
		load( faceData[DRAWING_FACES.TOP].texturePath ) 
	)
	
	# for key in faceData:
	#	draw_colored_polygon( faceData[key].points , faceData[key].shading , faceData[key].uvs , load( faceData[key].texturePath ) )

func exportFinishedTexture():
	pass

func updateBlockType( newBlockType : int = IsoPanel.IsoPanel.BLOCK_TYPES.NONE ):
	blockType = newBlockType
	drawAllPolygons( faceData , zoomLevel )
	
func updateFacingType( newFacingType : int = IsoPanel.IsoPanel.BLOCK_TYPES.NONE ):
	direction = newFacingType
	drawAllPolygons( faceData , zoomLevel )

func _calculateZoomLevel( zoomChange ):
	zoomLevel = zoomChange
	print(zoomLevel)
	if( zoomLevel != 1.0 ):
		for facingKey in faceData:
			zoomedFaceData[facingKey].points = PoolVector2Array()
			
			for idx in range( 0 , faceData[facingKey].points.size() ):
				zoomedFaceData[facingKey].points.append(faceData[facingKey].points[idx] * zoomLevel)
	else:
		for facingKey in faceData:
			zoomedFaceData[facingKey].points = faceData[facingKey].points

# Default UVs
func generateLeftFace( shrinkAmount ):
	var leftFace = PoolVector2Array()
	
	leftFace.append(Vector2( 0, tileRadius * .5 + shrinkAmount) + offset )
	leftFace.append(Vector2( tileRadius, tileRadius + shrinkAmount) + offset )
	leftFace.append(Vector2( tileRadius, tileRadius * 2) + offset )
	leftFace.append(Vector2( 0, 1.5 * tileRadius) + offset )
	
	faceData[DRAWING_FACES.LEFT].points = leftFace
	faceData[DRAWING_FACES.LEFT].uvs = fullFaceUvs
	
func generateRightFace( shrinkAmount ):
	var rightFace = PoolVector2Array()
	
	rightFace.append(Vector2(tileRadius * 2, tileRadius * .5 + shrinkAmount) + offset)
	rightFace.append(Vector2(tileRadius, tileRadius + shrinkAmount) + offset)
	rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
	rightFace.append(Vector2(tileRadius * 2, 1.5 * tileRadius) + offset)
	
	faceData[DRAWING_FACES.RIGHT].points = rightFace
	faceData[DRAWING_FACES.RIGHT].uvs = fullFaceUvs
	
func generateTopFace( shrinkAmount ):
	var topFace = PoolVector2Array()
	
	topFace.append(Vector2(tileRadius, 0 + shrinkAmount ) + offset)
	topFace.append(Vector2(tileRadius * 2, tileRadius * .5 + shrinkAmount ) + offset)
	topFace.append(Vector2(tileRadius, tileRadius + shrinkAmount) + offset)
	topFace.append(Vector2(0, tileRadius * .5 + shrinkAmount ) + offset)
	
	faceData[DRAWING_FACES.TOP].points = topFace
	faceData[DRAWING_FACES.TOP].uvs = fullFaceUvs

# Generate Ramp
func generateLeftFaceRamp( shrinkAmount , direction ):
	var leftFace = PoolVector2Array()
	if direction == DIRECTION.LEFT:
		leftFace.append(Vector2(0, tileRadius * .5) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(0, 1.5 * tileRadius) + offset)
	if direction == DIRECTION.DOWN:
		leftFace.append(Vector2(0, tileRadius * 1.5) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(0, 1.5 * tileRadius) + offset)
	if direction == DIRECTION.RIGHT:
		leftFace.append(Vector2(0, tileRadius * 1.5) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(0, 1.5 * tileRadius) + offset)
	if direction == DIRECTION.UP:
		leftFace.append(Vector2(0, tileRadius * .5) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(0, 1.5 * tileRadius) + offset)
	
	faceData[DRAWING_FACES.LEFT].points = leftFace
	faceData[DRAWING_FACES.LEFT].uvs = rampFaceUVs[direction][DRAWING_FACES.LEFT]

func generateRightFaceRamp( shrinkAmount , direction ):
	
	var rightFace = PoolVector2Array()
	if direction == DIRECTION.LEFT:
		rightFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius * 2, 1.5 * tileRadius) + offset)
	if direction == DIRECTION.DOWN:
		rightFace.append(Vector2(tileRadius * 2, tileRadius * .5) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius * 2, 1.5 * tileRadius) + offset)
	if direction == DIRECTION.RIGHT:
		rightFace.append(Vector2(tileRadius * 2, tileRadius * .5) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius * 2, 1.5 * tileRadius) + offset)
	if direction == DIRECTION.UP:
		rightFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius * 2, 1.5 * tileRadius) + offset)
	
	faceData[DRAWING_FACES.RIGHT].points = rightFace
	faceData[DRAWING_FACES.RIGHT].uvs = rampFaceUVs[direction][DRAWING_FACES.RIGHT]
	
func generateTopFaceRamp( shrinkAmount , direction ):
	
	var topFace = PoolVector2Array()
	if direction == DIRECTION.LEFT:
		topFace.append(Vector2(tileRadius, 0) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		topFace.append(Vector2(0, tileRadius * .5) + offset)
	if direction == DIRECTION.DOWN:
		topFace.append(Vector2(tileRadius, 0) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * .5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		topFace.append(Vector2(0, tileRadius * 1.5) + offset)
	if direction == DIRECTION.RIGHT:
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * .5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(0, tileRadius * 1.5) + offset)
	if direction == DIRECTION.UP:
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(0, tileRadius * .5) + offset)
	
	faceData[DRAWING_FACES.TOP].points = topFace
	faceData[DRAWING_FACES.TOP].uvs = fullFaceUvs

# For Flat bottom corners
func generateTopCornerFace( shrinkAmount , direction ):
	var topFace = PoolVector2Array()
	
	if direction == DIRECTION.LEFT:
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		topFace.append(Vector2(0, tileRadius * .5) + offset)
	if direction == DIRECTION.DOWN:
		topFace.append(Vector2(tileRadius, 0) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		topFace.append(Vector2(0, tileRadius * 1.5) + offset)
	if direction == DIRECTION.RIGHT:
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * .5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		topFace.append(Vector2(0, tileRadius * 1.5) + offset)
	if direction == DIRECTION.UP:
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(0, tileRadius * 1.5) + offset)
	
	faceData[DRAWING_FACES.TOP].points = topFace
	faceData[DRAWING_FACES.TOP].uvs = fullFaceUvs

func generateLeftCornerFace( shrinkAmount, direction ):
	var leftFace = PoolVector2Array()
	if direction == DIRECTION.LEFT:
		leftFace.append(Vector2(0, tileRadius * .5) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(0, 1.5 * tileRadius) + offset)
	if direction == DIRECTION.UP:
		leftFace.append(Vector2(0, tileRadius * 1.5) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(0, 1.5 * tileRadius) + offset)
	
	faceData[DRAWING_FACES.LEFT].points = leftFace
	faceData[DRAWING_FACES.LEFT].uvs =  diamondInclineFaceUVs[direction][DRAWING_FACES.LEFT]

func generateRightCornerFace( shrinkAmount, direction ):
	var rightFace  = PoolVector2Array()
	
	if direction == DIRECTION.RIGHT:
		rightFace.append(Vector2(tileRadius * 2, tileRadius * .5) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius * 2, 1.5 * tileRadius) + offset)
	if direction == DIRECTION.UP:
		rightFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius * 2, 1.5 * tileRadius) + offset)
	
	faceData[DRAWING_FACES.RIGHT].points = rightFace
	faceData[DRAWING_FACES.RIGHT].uvs = diamondInclineFaceUVs[direction][DRAWING_FACES.RIGHT]

func generateFlatTopLeftCornerFace( shrinkAmount, direction ):
	var leftFace = PoolVector2Array()
	
	if direction == DIRECTION.LEFT:
		leftFace.append(Vector2(0, tileRadius * .5) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(0, 1.5 * tileRadius) + offset)
	if direction == DIRECTION.DOWN:
		leftFace.append(Vector2(0, tileRadius * .5) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(0, 1.5 * tileRadius) + offset)
	if direction == DIRECTION.RIGHT:
		leftFace.append(Vector2(0, tileRadius * 1.5) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(0, 1.5 * tileRadius) + offset)
	if direction == DIRECTION.UP:
		leftFace.append(Vector2(0, tileRadius * .5) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(0, 1.5 * tileRadius) + offset)
	
	faceData[DRAWING_FACES.LEFT].points = leftFace
	faceData[DRAWING_FACES.LEFT].uvs = flatTopFaceUVs[direction][DRAWING_FACES.LEFT]
	
func generateFlatTopRightCornerFace( shrinkAmount, direction ):
	var rightFace = PoolVector2Array()

	if direction == DIRECTION.LEFT:
		rightFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius * 2, 1.5 * tileRadius) + offset)
	else:
		rightFace.append(Vector2(tileRadius * 2, tileRadius * .5) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius * 2, 1.5 * tileRadius) + offset)
	
	faceData[DRAWING_FACES.RIGHT].points = rightFace
	faceData[DRAWING_FACES.RIGHT].uvs = flatTopFaceUVs[direction][DRAWING_FACES.RIGHT]

func generateFlatTopCornerFace( shrinkAmount, direction ):
	var topFace = PoolVector2Array()

	if direction == DIRECTION.LEFT:
		topFace.append(Vector2(tileRadius, 0) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(0, tileRadius * .5) + offset)
	if direction == DIRECTION.DOWN:
		topFace.append(Vector2(tileRadius, 0) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * .5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		topFace.append(Vector2(0, tileRadius * .5) + offset)
	if direction == DIRECTION.RIGHT:
		topFace.append(Vector2(tileRadius, 0) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * .5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(0, tileRadius * 1.5) + offset)
	if direction == DIRECTION.UP:
		topFace.append(Vector2(tileRadius, tileRadius * .5) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * .5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(0, tileRadius * .5) + offset)
	
	faceData[DRAWING_FACES.TOP].points = topFace
	faceData[DRAWING_FACES.TOP].uvs = fullFaceUvs

# Signals
func _on_ZoomPlus_pressed():
	drawAllPolygons( faceData , zoomLevel - 0.1 )
	zoomLabel.set_text( str(zoomLevel * 100.0) + "%" )

func _on_ZoomMinus_pressed():
	drawAllPolygons( faceData , zoomLevel - 0.1 )
	zoomLabel.set_text( str(zoomLevel * 100.0) + "%" )

func _on_ResetButton_pressed():
	drawAllPolygons( faceData , 1.0 )
