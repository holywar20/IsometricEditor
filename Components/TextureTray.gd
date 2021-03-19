extends PanelContainer

signal texture_chosen(texture)

const THUMB_SIZE = 64

export(Array, Texture) var texture_list

var Previewer = preload("res://Components/PreviewButton.gd")
var is_expanded = false

onready var preview_button = get_node("PreviewButton")
onready var chooser_popup = get_node("TextureChoosePopup")
onready var chooser_hbox = get_node("TextureChoosePopup/TextureHBox")

func _ready():
	preview_button.preview_texture = texture_list[0]
	for full_texture in texture_list:
		add_thumbnail(full_texture)

func add_thumbnail(tex):
	if chooser_hbox.get_child_count() >= texture_list.size():
		return
	var option = Previewer.new()
	option.rect_min_size = Vector2(THUMB_SIZE, THUMB_SIZE)
	option.preview_texture = tex
	chooser_hbox.add_child(option)
	option.connect("choice_made", self, "_on_choice_made")

func _on_PreviewButton_pressed():
	is_expanded = true
	chooser_popup.popup(get_bar_rect(texture_list.size()))

func get_bar_rect(list_size : int):
	var origin = Vector2(rect_position.x + rect_size.x, rect_position.y)
	origin += Vector2(12, 8)
	var popsize = Vector2(THUMB_SIZE * list_size, THUMB_SIZE)
	return Rect2(origin, popsize)

func _on_TextureChoosePopup_popup_hide():
	is_expanded = false

func _on_choice_made(texture_choice):
	chooser_popup.hide()
	preview_button.preview_texture = texture_choice
	preview_button.update()
	emit_signal("texture_chosen", texture_choice)