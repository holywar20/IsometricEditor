tool
extends Panel
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

enum STATE {
	LAST_FOCUSED , NOT_FOCUSED
}

signal newSingleTextureSelected( overrides , node )

# Display
onready var highlight : TextureRect = $Highlight

# Controls
onready var resultsDisplay : Panel = $VBox/Main/ResultDisplay

onready var blockSelector : MenuButton =  $VBox/Display/Type
var blockPopup : Popup

onready var facingSelector : MenuButton = $VBox/Display/Facing
var facingPopup : Popup

onready var nameEditor : LineEdit = $VBox/Display/TitleRow/NameEdit
onready var tileDisplay : Label = $VBox/Main/ResultDisplay/TileSize

export(bool) var isFirst = false
export(BLOCK_TYPES) var blockType = BLOCK_TYPES.NONE 
export(DIRECTION) var direction = DIRECTION.LEFT 

var settings : Settings.SettingsData

# Local Settings & State
var textureName = "Undefined Texture"

var state = STATE.NOT_FOCUSED
var localState = {
	0 : TextureTray.TrayData.new( 0 ),
	1 : TextureTray.TrayData.new( 1 ),
	2 : TextureTray.TrayData.new( 2 )
}

func _ready():
	blockPopup = blockSelector.get_popup()
	var _bConnect = blockPopup.connect("id_pressed", self, "_on_block_pressed")

	facingPopup = facingSelector.get_popup()
	var _fConnect = facingPopup.connect("id_pressed" , self , "_on_facing_pressed")

	redrawBlock( blockType , direction)

func setSettings( settingsData : Settings.SettingsData ):
	settings = settingsData
	updateUI()

func setupScene( settingsData : Settings.SettingsData  ):
	settings = settingsData

	if( isFirst ):
		_on_IsoPanel_focus_entered()
	else:
		_on_Panel_focus_exited()


func updateUI():
	tileDisplay.set_text( str( settings.tileSize ) )
	
	nameEditor.set_text("textureName")

	if( blockType == BLOCK_TYPES.BOX || blockType == BLOCK_TYPES.NONE ):
		facingSelector.hide()
	else:
		facingSelector.show()

	_on_block_pressed( blockType , false )
	_on_facing_pressed( direction , false )

	resultsDisplay.setupScene( settings.tileSize , blockType , direction )

func updateTray( drawingFace : int  , tray : TextureTray.TrayData ):
	pass

func setState( newState ):
	state = newState

	match state:
		STATE.LAST_FOCUSED:
			highlight.show()
		STATE.NOT_FOCUSED:
			highlight.hide()

func _on_DeleteButton_pressed():
	queue_free()

func redrawBlock( blockId , facingId ):
	# First set any local params
	blockType = blockId
	direction = facingId

	blockSelector.set_text(TEXTURE_TYPE_PROPS[blockId].display)
	facingSelector.set_text(DIR_DISPLAY[facingId])

	if( blockType == BLOCK_TYPES.BOX || blockType == BLOCK_TYPES.NONE ):
		facingSelector.hide()
	else:
		facingSelector.show()
	
	# Now tell children to actually update
	resultsDisplay.updateBlockType( blockId, facingId )

func _on_block_pressed(id , grabFocus = true ):
	redrawBlock( id , resultsDisplay.direction )

	# Sometimes we don't want to grab focus on redraw, such as if we are doing a global update
	if( grabFocus ):
		_on_IsoPanel_focus_entered()


func _on_facing_pressed(id, grabFocus = false ):
	redrawBlock( resultsDisplay.direction, id )

	# Sometimes we don't want to grab focus on redraw, such as if we are doing a global update
	if( grabFocus ):
		_on_IsoPanel_focus_entered()

func _on_NameEdit_text_entered( new_text ):
	# TODO - do some shit with the name?
	
	_on_IsoPanel_focus_entered()

func _on_NameEdit_focus_entered():
	emit_signal( "newSingleTextureSelected" , localState , self )

func _on_IsoPanel_focus_entered():
	emit_signal( "newSingleTextureSelected" , localState , self )

func _on_BlockSelector_pressed():
	emit_signal( "newSingleTextureSelected" , localState , self )

func _on_DirectionSelector_pressed():
	emit_signal( "newSingleTextureSelected" , localState , self )

func _on_Panel_focus_exited():
	setState( STATE.NOT_FOCUSED )



