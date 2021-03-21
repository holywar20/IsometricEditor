tool
extends Panel

onready var drawPanel = $Panel

onready var titleDisplay : Label = $TitleDisplay
onready var sizeDisplay : Label = $SizeDisplay
onready var facingDisplay : Label = $FacingDisplay 

enum TEXTURE_TYPES {
	NONE , BOX , EVEN_INCLINE , DIAMOND_INCLINE, FLAT_TOP_CORNER, FLAT_BASE_CORNER 
}

const TEXTURE_TYPE_PROPS = {
	TEXTURE_TYPES.NONE : {
		"display" : "None"
	},
	TEXTURE_TYPES.BOX : {
		"display" : "Box"
	} ,
	TEXTURE_TYPES.EVEN_INCLINE : {
		"display" : "Even Incline"
	},
	TEXTURE_TYPES.DIAMOND_INCLINE : {
		"display" : "Diamond Incline"
	} ,
	TEXTURE_TYPES.FLAT_TOP_CORNER : {
		"display" : "Flat Top Corner"
	},
	TEXTURE_TYPES.FLAT_BASE_CORNER : {
		"display" : "Flat Top Corner"
	}
}

var fullFaceUvs = PoolVector2Array([
	Vector2(0, 0) ,  Vector2(1, 0) , Vector2(1, 1) , Vector2(0, 1)
])

var halfFaceUvs = PoolVector2Array([
	Vector2(0, 0.5), Vector2(1, 0.5), Vector2(1, 1) ,Vector2(0, 1)
])

var cornerFaceUvs = PoolVector2Array([
	
])

var rampFaceUVs  = [
	# LEFT RAMP
	PoolVector2Array([
		Vector2(0, 0) , Vector2(1, 1) , Vector2(1, 1) , Vector2(0, 1)
	]),
	# DOWN RAMP
	PoolVector2Array([
		Vector2(0, 0) , Vector2(1, 0), Vector2(1, 1) , Vector2(0, 1)
	]),
	# Right Ramp 
	PoolVector2Array([
		Vector2(0, 0) , Vector2( 1, 0 ), Vector2( 1 , 1), Vector2(0 , 1)
	]),
	# UP RAMP
	PoolVector2Array([
		Vector2(0, 1) , Vector2(1, 0) , Vector2(1, 1) , Vector2(0, 1)
	])
]
enum DIRECTION {
	LEFT , RIGHT, UP, DOWN 
}
const DIR_VECTORS = {
	DIRECTION.LEFT : Vector2.LEFT,
	DIRECTION.RIGHT : Vector2.RIGHT, 
	DIRECTION.UP : Vector2.UP,
	DIRECTION.DOWN : Vector2.DOWN
}
const DIR_DISPLAY = {
	DIRECTION.LEFT : "Left" , 
	DIRECTION.RIGHT  : "Right",
	DIRECTION.UP : "Up",
	DIRECTION.DOWN : "Down"
}

export(TEXTURE_TYPES) var myType = TEXTURE_TYPES.EVEN_INCLINE 
export(DIRECTION) var direction = DIRECTION.LEFT 

var tileRadius = 72
var offset = Vector2(15, 15)

enum DRAWING_FACES{
	LEFT , RIGHT , TOP
}

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

var faceData = null

func _ready():
	setupScene( 72 )
	
func setupScene( myTileRadius  ):
	faceData = DEFAULT_FACING_DATA.duplicate( true ) 
	
	tileRadius = myTileRadius
	
	titleDisplay.set_text( TEXTURE_TYPE_PROPS[myType].display )
	sizeDisplay.set_text( str(tileRadius) + " px" )

	if( myType == TEXTURE_TYPES.BOX || myType == TEXTURE_TYPES.NONE ):
		facingDisplay.set_text("")
		facingDisplay.hide()
	else:	
		facingDisplay.set_text( DIR_DISPLAY[direction] )
		facingDisplay.show()

	drawTextures()



func changeTextureType():
	pass

func drawTextures():
	print( myType )
	match myType:
		TEXTURE_TYPES.NONE:
			faceData = DEFAULT_FACING_DATA.duplicate( true ) 
		TEXTURE_TYPES.BOX:
			generateLeftFace( 0 )
			generateRightFace( 0 )
			generateTopFace( 0 )
		TEXTURE_TYPES.EVEN_INCLINE:
			generateLeftFaceRamp( 0 ,  DIR_VECTORS[direction] )
			generateRightFaceRamp( 0 , DIR_VECTORS[direction] )
			generateTopFaceRamp( 0 , DIR_VECTORS[direction] )
		TEXTURE_TYPES.DIAMOND_INCLINE:
			generateLeftCornerFace( 0 , DIR_VECTORS[direction] )
			generateRightCornerFace( 0 , DIR_VECTORS[direction] )
			generateTopCornerFace( 0 , DIR_VECTORS[direction] )
		TEXTURE_TYPES.FLAT_TOP_CORNER:
			pass
		TEXTURE_TYPES.FLAT_BASE_CORNER:
			pass 
	
	drawPanel.drawAllPolygons( faceData )

# Generate flat faces
func generateLeftFace( shrinkAmount ):
	var leftFace = PoolVector2Array()
	
	leftFace.append(Vector2( 0, tileRadius / 2 + shrinkAmount) + offset )
	leftFace.append(Vector2( tileRadius, tileRadius + shrinkAmount) + offset )
	leftFace.append(Vector2( tileRadius, tileRadius * 2) + offset )
	leftFace.append(Vector2( 0, 1.5 * tileRadius) + offset )
	
	faceData[DRAWING_FACES.LEFT].points = leftFace
	faceData[DRAWING_FACES.LEFT].uvs = fullFaceUvs
	
func generateRightFace( shrinkAmount ):
	var rightFace = PoolVector2Array()
	
	rightFace.append(Vector2(tileRadius * 2, tileRadius / 2 + shrinkAmount) + offset)
	rightFace.append(Vector2(tileRadius, tileRadius + shrinkAmount) + offset)
	rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
	rightFace.append(Vector2(tileRadius * 2, 1.5 * tileRadius) + offset)
	
	faceData[DRAWING_FACES.RIGHT].points = rightFace
	faceData[DRAWING_FACES.RIGHT].uvs = fullFaceUvs
	
func generateTopFace( shrinkAmount ):
	var topFace = PoolVector2Array()
	
	topFace.append(Vector2(tileRadius, 0 + shrinkAmount ) + offset)
	topFace.append(Vector2(tileRadius * 2, tileRadius / 2 + shrinkAmount ) + offset)
	topFace.append(Vector2(tileRadius, tileRadius + shrinkAmount) + offset)
	topFace.append(Vector2(0, tileRadius / 2 + shrinkAmount ) + offset)
	
	faceData[DRAWING_FACES.TOP].points = topFace
	faceData[DRAWING_FACES.TOP].uvs = fullFaceUvs

# Generate Ramp
func generateLeftFaceRamp( shrinkAmount , direction ):
	var leftFace = PoolVector2Array()
	if direction == Vector2.LEFT:
		leftFace.append(Vector2(0, tileRadius / 2) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(0, 1.5 * tileRadius) + offset)
	if direction == Vector2.DOWN:
		leftFace.append(Vector2(0, tileRadius * 1.5) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(0, 1.5 * tileRadius) + offset)
	if direction == Vector2.RIGHT:
		leftFace.append(Vector2(0, tileRadius * 1.5) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(0, 1.5 * tileRadius) + offset)
	if direction == Vector2.UP:
		leftFace.append(Vector2(0, tileRadius / 2) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(0, 1.5 * tileRadius) + offset)
	
	faceData[DRAWING_FACES.LEFT].points = leftFace
	faceData[DRAWING_FACES.LEFT].uvs = fullFaceUvs

func generateRightFaceRamp( shrinkAmount , direction ):
	
	var rightFace = PoolVector2Array()
	if direction == Vector2.LEFT:
		rightFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius * 2, 1.5 * tileRadius) + offset)
	if direction == Vector2.DOWN:
		rightFace.append(Vector2(tileRadius * 2, tileRadius / 2) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius * 2, 1.5 * tileRadius) + offset)
	if direction == Vector2.RIGHT:
		rightFace.append(Vector2(tileRadius * 2, tileRadius / 2) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius * 2, 1.5 * tileRadius) + offset)
	if direction == Vector2.UP:
		rightFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius * 2, 1.5 * tileRadius) + offset)
	
	faceData[DRAWING_FACES.RIGHT].points = rightFace
	faceData[DRAWING_FACES.RIGHT].uvs = fullFaceUvs
	
func generateTopFaceRamp( shrinkAmount , direction ):
	
	var topFace = PoolVector2Array()
	if direction == Vector2.LEFT:
		topFace.append(Vector2(tileRadius, 0) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		topFace.append(Vector2(0, tileRadius / 2) + offset)
	if direction == Vector2.DOWN:
		topFace.append(Vector2(tileRadius, 0) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius / 2) + offset)
		topFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		topFace.append(Vector2(0, tileRadius * 1.5) + offset)
	if direction == Vector2.RIGHT:
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius / 2) + offset)
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(0, tileRadius * 1.5) + offset)
	if direction == Vector2.UP:
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(0, tileRadius / 2) + offset)
	
	faceData[DRAWING_FACES.TOP].points = topFace
	faceData[DRAWING_FACES.TOP].uvs = fullFaceUvs

# For Flat bottom corners
func generateTopCornerFace( shrinkAmount , direction ):
	var topFace = PoolVector2Array()
	
	if direction == Vector2.LEFT:
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		topFace.append(Vector2(0, tileRadius / 2) + offset)
	if direction == Vector2.DOWN:
		topFace.append(Vector2(tileRadius, 0) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		topFace.append(Vector2(0, tileRadius * 1.5) + offset)
	if direction == Vector2.RIGHT:
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius / 2) + offset)
		topFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		topFace.append(Vector2(0, tileRadius * 1.5) + offset)
	if direction == Vector2.UP:
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		topFace.append(Vector2(tileRadius, tileRadius) + offset)
		topFace.append(Vector2(0, tileRadius * 1.5) + offset)
	
	faceData[DRAWING_FACES.TOP].points = topFace
	faceData[DRAWING_FACES.TOP].uvs = fullFaceUvs

func generateLeftCornerFace( shrinkAmount, direction ):
	var leftFace = PoolVector2Array()
	if direction == Vector2.LEFT:
		leftFace.append(Vector2(0, tileRadius / 2) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(0, 1.5 * tileRadius) + offset)
	if direction == Vector2.UP:
		leftFace.append(Vector2(0, tileRadius * 1.5) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius) + offset)
		leftFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		leftFace.append(Vector2(0, 1.5 * tileRadius) + offset)
	
	faceData[DRAWING_FACES.LEFT].points = leftFace
	faceData[DRAWING_FACES.LEFT].uvs = fullFaceUvs

func generateRightCornerFace( shrinkAmount, direction ):
	var rightFace  = PoolVector2Array()
	if direction == Vector2.RIGHT:
		rightFace.append(Vector2(tileRadius * 2, tileRadius / 2) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius * 2, 1.5 * tileRadius) + offset)
	if direction == Vector2.UP:
		rightFace.append(Vector2(tileRadius * 2, tileRadius * 1.5) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius) + offset)
		rightFace.append(Vector2(tileRadius, tileRadius * 2) + offset)
		rightFace.append(Vector2(tileRadius * 2, 1.5 * tileRadius) + offset)
	
	faceData[DRAWING_FACES.RIGHT].points = rightFace
	faceData[DRAWING_FACES.RIGHT].uvs = fullFaceUvs
