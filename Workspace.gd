extends HBoxContainer

var load_key = ""
var remembered_load_directory = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
var remembered_save_directory = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)

onready var drawing_node = $MainVBox/ScrollContainer/WorkingAtlas/RenderingSurface/Draw
onready var atlas = $MainVBox/ScrollContainer/WorkingAtlas
onready var scrollbox = $MainVBox/ScrollContainer

onready var texture_trays = {
	"top" : $TexturePanel/VBoxContainer/TopTextureTray, 
	"left" : $TexturePanel/VBoxContainer/LeftTextureTray, 
	"right" : $TexturePanel/VBoxContainer/RightTextureTray
}

onready var color_pickers = {
	"top" : $SettingsPanel/VBoxContainer/TopColorPicker, 
	"left" : $SettingsPanel/VBoxContainer/LeftColorPicker, 
	"right" : $SettingsPanel/VBoxContainer/RightColorPicker
}

onready var save_dialog = $MainVBox/ControlPanel/HBoxContainer/ExportButton/ExportDialog
onready var load_dialog = $MainVBox/ControlPanel/HBoxContainer/ExportButton/LoadDialog

func _ready():
	pass
	#color_pickers.top.color = drawing_node.top_tint
	#color_pickers.left.color = drawing_node.left_tint
	#color_pickers.right.color = drawing_node.right_tint
	#texture_trays.top.preview_button.preview_texture = drawing_node.top_texture
	#texture_trays.left.preview_button.preview_texture = drawing_node.left_texture
	#texture_trays.right.preview_button.preview_texture = drawing_node.right_texture


func updateAll():
	pass

# UI Signals
func _on_ExportButton_pressed():
	save_dialog.current_dir = remembered_save_directory
	save_dialog.popup_centered()

func _on_ExportDialog_file_selected(path):
	var img = atlas.texture.get_data()
	img.save_png(path)
	remembered_save_directory = path.get_base_dir()


func _on_TopColorPicker_color_changed(color):
	drawing_node.top_tint = color
	drawing_node.update()


func _on_LeftColorPicker_color_changed(color):
	drawing_node.left_tint = color
	drawing_node.update()


func _on_RightColorPicker_color_changed(color):
	drawing_node.right_tint = color
	drawing_node.update()


func _on_RadiusSpin_value_changed(value):
	drawing_node.tile_radius = value
	drawing_node.update()
	atlas.rect_min_size = Vector2(value * drawing_node.SHEET_COLUMNS * 2, value * drawing_node.SHEET_ROWS * 2)
	atlas.update()


func _on_EdgeCheck_toggled(button_pressed):
	drawing_node.drop_top = button_pressed
	drawing_node.update()


func _on_TopTextureTray_texture_chosen(texture):
	drawing_node.top_texture = texture
	drawing_node.update()


func _on_LeftTextureTray_texture_chosen(texture):
	drawing_node.left_texture = texture
	drawing_node.update()


func _on_RightTextureTray_texture_chosen(texture):
	drawing_node.right_texture = texture
	drawing_node.update()


func _on_AnyLoadButton_pressed(which):
	load_dialog.current_dir = remembered_load_directory
	load_key = which
	load_dialog.popup_centered()

func _on_LoadDialog_file_selected(path):
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
		texture_trays[load_key].texture_list.append(new_texture)
		for tray in texture_trays.values():
			tray.add_thumbnail(new_texture)
		texture_trays[load_key]._on_choice_made(new_texture)
	load_key = ""
	remembered_load_directory = path.get_base_dir()


func _on_BevelCheck_toggled(button_pressed):
	drawing_node.bevel_top = button_pressed
	drawing_node.update()


func _on_GranuleSlider_value_changed(value):
	drawing_node.granules = value
	drawing_node.update()


func _on_WarpSlider_value_changed(value):
	drawing_node.warp = value
	drawing_node.update()


func _on_OutlineCheckBox_toggled(button_pressed):
	drawing_node.outline_shadow = button_pressed
	drawing_node.update()




