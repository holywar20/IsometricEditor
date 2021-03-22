extends Button

signal choice_made(chosen_texture)

var preview_texture : Texture

func _ready():
	connect("pressed", self, "_on_choice")

func _draw():
	if preview_texture:
		draw_texture_rect(preview_texture, Rect2(Vector2.ZERO, rect_min_size), false, Color.white)

func _on_choice():
	emit_signal("choice_made", preview_texture)
