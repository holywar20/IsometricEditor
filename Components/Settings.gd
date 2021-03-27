extends WindowDialog
class_name Settings

class SettingsData:
	var defaultTexturePath = "C:/"
	var normalTexturePath = "C:/"
	
	var tileColumns = 6
	var tileSize = 72

	func _init():
		pass

# Controls
onready var dataDisplay = {
	"defaultTexturePath" : $MainVB/Data/Left/DefaultTexturePath/LineEdit,
	"normalTexturePath" : $MainVB/Data/Left/NormalTexturePath/LineEdit,

	"tileColumns" : $MainVB/Data/Right/TileColumns/TileColumnsValue,
	"tileSize" : $MainVB/Data/Right/TileColumns/TileSizeValue
}

signal settingsSaved( settingData )

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func populateSettings( settings : SettingsData ):
	dataDisplay.defaultTexturePath.set_text( settings.defaultTexturePath )
	dataDisplay.normalTexturePath.set_text( settings.normalTexturePath )	
	dataDisplay.tileColumns.set_value( settings.tileColumns )
	dataDisplay.tileSize.set_value( settings.tileSize )

func _on_Cancel_pressed():
	hide()

func _on_SaveButton_pressed():
	var settingsData = SettingsData.new()

	settingsData.defaultTexturePath = dataDisplay.defaultTexturePath.get_text()
	settingsData.normalTexturePath = dataDisplay.normalTexturePath.get_text()
	settingsData.tileColumns = dataDisplay.tileColumns.get_value()
	settingsData.tileSize = dataDisplay.tileSize.get_value()

	emit_signal("settingsSaved", settingsData )

	hide()
