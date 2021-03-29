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
	"settings" : $Popups/Settings
}
var globalSettings = Settings.SettingsData.new()

# onready var save_dialog = $MainVBox/ControlPanel/HBoxContainer/ExportButton/ExportDialog
# onready var load_dialog = $MainVBox/ControlPanel/HBoxContainer/ExportButton/LoadDialog

var currentFocusNode : IsoPanel

func _ready():
	for key in globalTextureTrays:
		globalTextureTrays[key].setSettings( globalSettings )

	for key in localTextureTrays:
		localTextureTrays[key].setSettings( globalSettings )

	# Set up initial selection
	for child in get_tree().get_nodes_in_group( TILE_PANELS ):
		child.setSettings( globalSettings )
		if( child.isFirst ):
			_on_newSingleTextureSelected( child )
			
# Settings Panel Menu actions
func _on_Settings_pressed():
	# Populate with duplicate data so if user changes but cancels, data doesn't change globally
	popups.settings.popup()
	popups.settings.populateSettings( globalSettings )

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
	
	print( settingsData.defaultTexturePath )

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

# Selecting a single texture 
func _on_newSingleTextureSelected( node ):
	print(node)
	
	for child in get_tree().get_nodes_in_group( TILE_PANELS ):
		child.setState( child.STATE.NOT_FOCUSED )

	node.setState( node.STATE.LAST_FOCUSED )
	currentFocusNode = node

	# Now update my current texture settings
	for facingKey in node.localState:
		pass

# Tray changes
func _on_Current_trayChanged( tray : TextureTray.TrayData ):
	for child in isoPlanelBase.get_children():
		print( child , currentFocusNode )
		if( child == currentFocusNode ):
			currentFocusNode.updateTray( tray )
			break

func _on_Global_trayChanged( tray : TextureTray.TrayData  ):
	for child in get_tree().get_nodes_in_group( TILE_PANELS ):
		child.updateTray( tray  )

# Global Menus
func _on_TextureLibButton_button_down():
	pass # Replace with function body.

func _on_Top_texture_chosen(texture):
	pass # Replace with function body.

# UI Signals
func _on_ExportButton_pressed():
	pass
	# save_dialog.current_dir = remembered_save_directory
	# save_dialog.popup_centered()

func _on_ExportDialog_file_selected(path):
	pass
	# var img = atlas.texture.get_data()
	# img.save_png(path)
	# remembered_save_directory = path.get_base_dir()


func _on_TopColorPicker_color_changed(color):
	pass
	# drawing_node.top_tint = color
	# drawing_node.update()

func _on_LeftColorPicker_color_changed(color):
	pass
	# drawing_node.left_tint = color
	# drawing_node.update()

func _on_RightColorPicker_color_changed(color):
	pass
	# drawing_node.right_tint = color
	# drawing_node.update()

func _on_RadiusSpin_value_changed(value):
	pass
	# drawing_node.tile_radius = value
	# drawing_node.update()
	# atlas.rect_min_size = Vector2(value * drawing_node.SHEET_COLUMNS * 2, value * drawing_node.SHEET_ROWS * 2)
	# atlas.update()

func _on_EdgeCheck_toggled(button_pressed):
	pass
	# drawing_node.drop_top = button_pressed
	# drawing_node.update()

func _on_TopTextureTray_texture_chosen(texture):
	pass
	# drawing_node.top_texture = texture
	# drawing_node.update()

func _on_LeftTextureTray_texture_chosen(texture):
	pass
	# drawing_node.left_texture = texture
	# drawing_node.update()

func _on_RightTextureTray_texture_chosen(texture):
	pass
	# drawing_node.right_texture = texture
	# drawing_node.update()

func _on_AnyLoadButton_pressed(which):
	pass
	# load_dialog.current_dir = remembered_load_directory
	# load_key = which
	# load_dialog.popup_centered()

func _on_LoadDialog_file_selected(path):
	"""
	var file = File.new()
	file.open(path, File.READ)
	var bytebin = file.get_buffer(file.get_len())
	file.close()
	if load_key:
		var img = Image.new()
		var error = img.load_png_from_buffer(bytebin)
		if error:
			print(error)
			return
		if img.get_size().x > 256 and img.get_size().y > 256:
			img.resize(256, 256, Image.INTERPOLATE_CUBIC)
		var new_texture = ImageTexture.new()
		new_texture.create_from_image(img)
		[load_key].texture_list.append(new_texture)
		for tray in texture_trays.values():
			tray.add_thumbnail(new_texture)
		texture_trays[load_key]._on_choice_made(new_texture)
	load_key = ""
	remembered_load_directory = path.get_base_dir()
	"""


func _on_BevelCheck_toggled(button_pressed):
	pass
	# drawing_node.bevel_top = button_pressed
	# drawing_node.update()

func _on_GranuleSlider_value_changed(value):
	pass
	# drawing_node.granules = value
	# drawing_node.update()

func _on_WarpSlider_value_changed(value):
	pass
	# drawing_node.warp = value
	# drawing_node.update()

func _on_OutlineCheckBox_toggled(button_pressed):
	pass
	# drawing_node.outline_shadow = button_pressed
	# drawing_node.update()
