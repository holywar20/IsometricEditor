extends PanelContainer
class_name TextureTray

# Needs to be identical to Results Panel.
enum DRAWING_FACES{
	LEFT , RIGHT , TOP
}

enum TEXTURE_TYPE {
	BASIC, NORMAL
}

var previewButton = preload("res://Components/Preview.tscn")

export(Array, Texture) var texture_list
export(String) var labelName = "Top"
export(DRAWING_FACES) var facingId = DRAWING_FACES.TOP
export(TEXTURE_TYPE) var texType = TEXTURE_TYPE.BASIC
export(bool) var isGlobal = false

var loadedTextureList : Array = [] 

# State
var myTextureTarget = null

# Display
onready var trayLabel = $VBox/TextureLabel

# Controls
onready var textureSelectButton = $VBox/Texture/TextureButton
onready var normalSelectButton = $VBox/Normal/NormalButton
onready var colorSelectButton = $VBox/ColorPickerButton
onready var visibleButton = $VBox/CheckBox

# Popups
onready var chooserPopup = $Popups/TextureChoosePopup
onready var chooserBase = $Popups/TextureChoosePopup/Textures
onready var fileDialog = $Popups/FileDialog

# TODO - make into a settings resource
var settings : Settings.SettingsData

signal trayChanged( tray )
signal textureSelected( type , trayFacingId , texture , globalState )

class TrayData:
	var trayFacingId

	var texture = null
	var normal = null
	var color = null
	var visible = null

	func _init( facingId , data = null ):
		trayFacingId = facingId

		if( data ):
			_mergeNewData( data )

	# This accepts local tray data, if a global texture tray created it.
	# Essentially we are merging the texture trays.
	func _mergeNewData( data : Dictionary ):
		if( data.has("texture")  ):
			texture = data.texture

		if( data.has("normal") ):
			normal = data.texture

		if( data.has("color") ):
			color = data.color

		if( data.has("visible" ) ):
			visible = data.visible
		
func is_class( testName ):
	return testName == "TextureTray"

func get_class():
	return "TextureTray"

func setSettings( newSettings ):
	settings = newSettings

func setupScene():
	pass

func _ready():
	textureSelectButton.set_normal_texture( texture_list[0] ) 
	normalSelectButton.set_normal_texture( texture_list[0] ) 
	
	trayLabel.set_text( labelName )

func _add_thumbnail( texture ):
	if chooserBase.get_child_count() >= texture_list.size():
		return
	
	var previewInstance = previewButton.instance()
	chooserBase.add_child( previewInstance )
	previewInstance.setupScene( texture )

	previewInstance.connect("textureSelected", self, "_on_Chooser_textureSelected")

func _makeTray():
	var trayData = {
		"texture" : textureSelectButton.get_normal_texture(),
		"normal" : normalSelectButton.get_normal_texture(),
		"color" : colorSelectButton.get_pick_color(),
		"visible" : visibleButton.is_pressed()
	}

	var newTray = TrayData.new( facingId,  trayData )
	return newTray

func get_bar_rect(list_size : int):
	var origin = Vector2(rect_position.x + rect_size.x, rect_position.y)
	origin += Vector2(12, 8)
	var popsize = Vector2(TexturePreview.THUMB_SIZE) * list_size
	
	return Rect2(origin, popsize)

# Texture Picker
func _on_TextureChoosePopup_popup_hide():
	pass

func _on_Chooser_textureSelected( chosenTexture ):
	chooserPopup.hide()

	myTextureTarget.set_normal_texture( chosenTexture )
	myTextureTarget = null

	emit_signal("trayChanged", _makeTray() )

func _on_TextureButton_pressed():
	emit_signal( "textureSelected" , TEXTURE_TYPE.BASIC , self )

func _on_NormalButton_pressed():
	emit_signal( "textureSelected" , TEXTURE_TYPE.NORMAL , self )

# File loading
func _on_LoadTextureButton_pressed():
	myTextureTarget = textureSelectButton

	fileDialog.rect_position = get_global_mouse_position()
	fileDialog.set_current_dir( settings.defaultTexturePath )
	fileDialog.set_filters(PoolStringArray(["*.png ; PNG Images"]))
	fileDialog.popup()

func _on_LoadNormalButton_pressed():
	myTextureTarget = normalSelectButton

	fileDialog.rect_position = get_global_mouse_position()
	fileDialog.set_current_dir( settings.defaultNormalPath )
	fileDialog.set_filters(PoolStringArray(["*.png ; PNG Images"]))
	fileDialog.popup()

func _on_FileDialog_file_selected( filePath ):
	if( filePath ):
		emit_signal("newTextureAdded" , filePath )
		emit_signal("trayChanged", _makeTray() )

	
