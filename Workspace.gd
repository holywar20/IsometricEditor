extends HBoxContainer

const TILE_PANELS = "TILE_PANELS"

var load_key = ""
var remembered_load_directory = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
var remembered_save_directory = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)

onready var singleTextureScene = preload("res://SingleTextureContainer/SingleTextureContainer.tscn")
onready var newTextureButton = preload("res://Components/TextureButton.tscn")

onready var isoPlanelBase : GridContainer =  $MainVBox/MainPanel/GridScroll/GridContainer

onready var globalTextureTrays = {
	TextureTray.DRAWING_FACES.TOP : $Controls/Global/Trays/Top, 
	TextureTray.DRAWING_FACES.LEFT: $Controls/Global/Trays/Right, 
	TextureTray.DRAWING_FACES.RIGHT: $Controls/Global/Trays/Left
}

onready var localTextureTrays = {
	TextureTray.DRAWING_FACES.TOP : $Controls/Current/Trays/Top, 
	TextureTray.DRAWING_FACES.LEFT: $Controls/Current/Trays/Left, 
	TextureTray.DRAWING_FACES.RIGHT : $Controls/Current/Trays/Right
}

onready var popups = {
	"settings" : $Popups/Settings,
	"chooser" : $Popups/TextureChoosePopup
}

var recentTextures = []
var globalSettings : Settings.SettingsData

# onready var save_dialog = $MainVBox/ControlPanel/HBoxContainer/ExportButton/ExportDialog
# onready var load_dialog = $MainVBox/ControlPanel/HBoxContainer/ExportButton/LoadDialog

var currentFocusNode : IsoPanel

func _ready():
	globalSettings = popups.settings.mySettings
	
	for key in globalTextureTrays:
		globalTextureTrays[key].setSettings( globalSettings )

	for key in localTextureTrays:
		localTextureTrays[key].setSettings( globalSettings )

	# Set up initial selection
	for child in get_tree().get_nodes_in_group( TILE_PANELS ):
		child.setSettings( globalSettings )
		if( child.isFirst ):
			# Fire signal method manually to set apps initial state.
			_on_newSingleTextureSelected( child )
			
# Settings Panel Menu actions
func _on_Settings_pressed():
	# Populate with duplicate data so if user changes but cancels, data doesn't change globally
	popups.settings.popup()

	for child in get_tree().get_nodes_in_group( TILE_PANELS ):
		child.setSettings( globalSettings )

	for key in globalTextureTrays:
		globalTextureTrays[key].setSettings( globalSettings )

	for key in localTextureTrays:
		localTextureTrays[key].setSettings( globalSettings )
	
func _on_Settings_saved( newGlobalSettings ):
	globalSettings = newGlobalSettings
	popups.hide()

func _on_Settings_settingsSaved(settingsData):
	globalSettings = settingsData

#  Texture actions
func _on_NewTextureButton_pressed():
	var oldTextureButton = isoPlanelBase.get_child( isoPlanelBase.get_child_count() - 1 )
	oldTextureButton.queue_free()
	
	var singleTextureInstance = singleTextureScene.instance()

	isoPlanelBase.add_child( singleTextureInstance )
	singleTextureInstance.setupScene( globalSettings )

	var newTextureButtonInstance = newTextureButton.instance()
	isoPlanelBase.add_child( newTextureButtonInstance )
	newTextureButtonInstance.connect("pressed" , self , "_on_NewTextureButton_pressed" )

func _on_newSingleTextureSelected( node ):	
	for child in get_tree().get_nodes_in_group( TILE_PANELS ):
		child.setState( child.STATE.NOT_FOCUSED )

	node.setState( node.STATE.LAST_FOCUSED )
	currentFocusNode = node


# Tray changes
func _on_Current_trayChanged( tray : TextureTray.TrayData ):
	for child in isoPlanelBase.get_children():
		if( child == currentFocusNode ):
			currentFocusNode.updateTray( tray )
			break

func _on_Global_trayChanged( tray : TextureTray.TrayData  ):
	for child in get_tree().get_nodes_in_group( TILE_PANELS ):
		child.updateTray( tray  )

func _on_textureSelected( type, trayNode):
	var path = null
	match type:
		TextureTray.TEXTURE_TYPE.BASIC:
			path = globalSettings.defaultTexturePath
		TextureTray.TEXTURE_TYPE.NORMAL:
			path = globalSettings.normalTexturePath

	# TODO : Add recent to root textures

	popups.chooser.updateUI( path, recentTextures ,trayNode )	
	popups.chooser.popup()

func _on_textureSelectionComplete():
	pass
