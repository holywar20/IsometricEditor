extends TextureButton
class_name TexturePreview

const THUMB_SIZE = Vector2(64 , 64)

var previewTexture : Texture

signal textureSelected( chosenTexture )

func _ready():
	set_custom_minimum_size( THUMB_SIZE )
	var _x = connect("pressed", self, "_on_choice")

func setupScene(  texture ):
	previewTexture = texture

	set_normal_texture( texture )
	set_size( THUMB_SIZE )

func _on_choice():
	emit_signal("textureSelected", previewTexture)
