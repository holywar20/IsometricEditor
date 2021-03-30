extends WindowDialog
class_name Settings

const SETTINGS_FILE_PATH = "res://Data/settings.json"

class SettingsData:
	var defaultTexturePath = null
	var normalTexturePath = null
	var exportTexturePath = null
	var exportTilesetPath = null

	var tileColumns = 6
	var tileSize = 72

	func _init( data = null ):
		if( data ):
			defaultTexturePath = data.defaultTexturePath
			normalTexturePath = data.normalTexturePath
			exportTexturePath = data.exportTexturePath
			exportTilesetPath = data.exportTilesetPath
			tileColumns = data.tileColumns
			tileSize = data.tileSize

	func getDataAsDict():
		return {
			"defaultTexturePath" : defaultTexturePath, 
			"normalTexturePath" : normalTexturePath,
			"exportTexturePath" : exportTexturePath, 
			"exportTilesetPath" : exportTilesetPath,
			"tileColumns" : tileColumns,
			"tileSize" : tileSize, 
		}

		
var mySettings : SettingsData

# Controls
onready var dataDisplay = {
	"defaultTexturePath" : $MainVB/Data/Left/DefaultTexturePath/LineEdit,
	"normalTexturePath" : $MainVB/Data/Left/NormalTexturePath/LineEdit,
	"exportTexturePath" : $MainVB/Data/Left/ExportTexturePath/LineEdit,
	"exportTilesetPath" : $MainVB/Data/Left/ExportTileSet/LineEdit,

	"tileColumns" : $MainVB/Data/Right/TileColumns/TileColumnsValue,
	"tileSize" : $MainVB/Data/Right/TileSize/TileSizeValue
}

onready var fileDialog : FileDialog = $FileDialog

enum DIALOG_STATE {
	DEFAULT , NORMAL , EXPORT_TEXTURES , EXPORT_TILESETS
}

var dialogState = DIALOG_STATE.DEFAULT

signal settingsSaved( settingData )

# Called when the node enters the scene tree for the first time.
func _ready():
	var settingsFile = File.new()
	settingsFile.open( SETTINGS_FILE_PATH , File.READ )

	var settingsDictionary = parse_json( settingsFile.get_as_text() )
	
	populateSettings( settingsDictionary )

	# Set up default file dialog beheavior.
	fileDialog.set_mode( FileDialog.MODE_OPEN_DIR )

func _saveSettings():
	var settingsFile = File.new()
	settingsFile.open( SETTINGS_FILE_PATH , File.WRITE )

	var dataDictionary = mySettings.getDataAsDict()
	settingsFile.store_string( JSON.print(dataDictionary) )
	settingsFile.close()


func populateSettings( settingsDictionary : Dictionary ):
	mySettings = SettingsData.new( settingsDictionary )
	
	dataDisplay.defaultTexturePath.set_text( mySettings.defaultTexturePath )
	dataDisplay.normalTexturePath.set_text( mySettings.normalTexturePath )	
	dataDisplay.exportTexturePath.set_text( mySettings.exportTexturePath )
	dataDisplay.exportTilesetPath.set_text( mySettings.exportTilesetPath ) 
	dataDisplay.tileColumns.set_value( mySettings.tileColumns )
	dataDisplay.tileSize.set_value( mySettings.tileSize )

func _on_Cancel_pressed():
	hide()

func _on_SaveButton_pressed():
	mySettings = SettingsData.new()

	mySettings.defaultTexturePath = dataDisplay.defaultTexturePath.get_text()
	mySettings.normalTexturePath = dataDisplay.normalTexturePath.get_text()
	mySettings.exportTexturePath = dataDisplay.exportTexturePath.get_text()
	mySettings.exportTilesetPath = dataDisplay.exportTilesetPath.get_text()

	mySettings.tileColumns = dataDisplay.tileColumns.get_value()
	mySettings.tileSize = dataDisplay.tileSize.get_value()

	_saveSettings()

	emit_signal("settingsSaved", mySettings )

	hide()

# File Dialog Signals
func _on_DefaultTexturePath_Button_pressed():
	fileDialog.set_current_dir( dataDisplay.defaultTexturePath.get_text() )
	fileDialog.window_title = "Set Texture Path."
	dialogState = DIALOG_STATE.DEFAULT
	fileDialog.popup()

func _on_NormalTexturePath_Button_pressed():
	fileDialog.set_current_dir( dataDisplay.normalTexturePath.get_text() )
	fileDialog.window_title = "Set Normal Path."
	dialogState = DIALOG_STATE.NORMAL
	fileDialog.popup()

func _on_ExportTexturePath_Button_pressed():
	fileDialog.set_current_dir( dataDisplay.exportTexturePath.get_text() )
	dialogState = DIALOG_STATE.EXPORT_TEXTURES
	fileDialog.window_title = "Set Tilesheet Path."
	fileDialog.popup()

func _on_ExportTileSet_Button_pressed():
	fileDialog.set_current_dir( dataDisplay.exportTilesetPath.get_text() )
	dialogState = DIALOG_STATE.EXPORT_TILESETS
	fileDialog.window_title = "Set Godot Tileset Path."
	fileDialog.popup()


func _on_FileDialog_dir_selected(dir):
	match dialogState:
		DIALOG_STATE.DEFAULT:
			dataDisplay.defaultTexturePath.set_text( dir )
		DIALOG_STATE.NORMAL:
			dataDisplay.normalTexturePath.set_text( dir )
		DIALOG_STATE.EXPORT_TEXTURES:
			dataDisplay.exportTexturePath.set_text( dir )
		DIALOG_STATE.EXPORT_TILESETS:
			dataDisplay.exportTexturePath.set_text( dir )
