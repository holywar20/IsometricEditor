tool
extends PanelContainer
class_name IsoPanel

"""
	IsoPanel is meant to hold all the meta data about a particular sprite but does not handle the
	sprite generation. Most controls should go here to keep event handling seperate from generation.
"""

enum BLOCK_TYPES {
	NONE , BOX , EVEN_INCLINE , DIAMOND_INCLINE, FLAT_TOP_CORNER, FLAT_BASE_CORNER 
}

enum DIRECTION {
	LEFT , DOWN , RIGHT, UP
}

const TEXTURE_TYPE_PROPS = {
	BLOCK_TYPES.NONE : {
		"display" : "Select a Block "
	},
	BLOCK_TYPES.BOX : {
		"display" : "Box"
	} ,
	BLOCK_TYPES.EVEN_INCLINE : {
		"display" : "Even Incline"
	},
	BLOCK_TYPES.DIAMOND_INCLINE : {
		"display" : "Diamond Incline"
	} ,
	BLOCK_TYPES.FLAT_TOP_CORNER : {
		"display" : "Flat Top Corner"
	},
	BLOCK_TYPES.FLAT_BASE_CORNER : {
		"display" : "Flat Base Corner"
	}
}

const DIR_DISPLAY = {
	DIRECTION.LEFT : "Left", DIRECTION.RIGHT : "Right" , DIRECTION.UP : "Up" , DIRECTION.DOWN : "Down"
}

# Controls
onready var resultsDisplay : Panel = $VBox/Main/ResultDisplay

onready var blockSelector : MenuButton =  $VBox/Display/Type
var blockPopup : Popup

onready var facingSelector : MenuButton = $VBox/Display/Facing
var facingPopup : Popup

onready var nameEditor : LineEdit = $VBox/Display/TitleRow/NameEdit
onready var tileDisplay : Label = $VBox/Main/ResultDisplay/TileSize

export(BLOCK_TYPES) var blockType = BLOCK_TYPES.NONE 
export(DIRECTION) var direction = DIRECTION.LEFT 
var tileRadius = 72
var textureName = "Undefined Texture"

func _ready():
	blockPopup = blockSelector.get_popup()
	var _bConnect = blockPopup.connect("id_pressed", self, "_on_block_pressed")

	facingPopup = facingSelector.get_popup()
	var _fConnect = facingPopup.connect("id_pressed" , self , "_on_facing_pressed") 

	setupScene( 72 )
	
func setupScene( myTileRadius  ):
	tileRadius = myTileRadius
	tileDisplay.set_text( str( tileRadius ) )
	
	nameEditor.set_text("textureName")

	if( blockType == BLOCK_TYPES.BOX || blockType == BLOCK_TYPES.NONE ):
		facingSelector.hide()
	else:
		facingSelector.show()

	# Fire off any events manually
	_on_block_pressed( blockType )
	_on_facing_pressed( direction )

	resultsDisplay.setupScene( tileRadius , blockType , direction )

func _on_DeleteButton_pressed():
	queue_free()

func _on_block_pressed(id):
	blockSelector.set_text(TEXTURE_TYPE_PROPS[id].display)
	
	if( blockType == BLOCK_TYPES.BOX || blockType == BLOCK_TYPES.NONE ):
		facingSelector.hide()
	else:
		facingSelector.show()
	
	resultsDisplay.blockType = id
	resultsDisplay.drawTextures()

func _on_facing_pressed(id):
	facingSelector.set_text(DIR_DISPLAY[id])

	resultsDisplay.direction = id
	resultsDisplay.drawTextures()


func _on_NameEdit_text_entered(new_text):
	print("New Text")
