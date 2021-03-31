extends TextureButton
class_name TexturePreview

const THUMB_SIZE = Vector2(64 , 64)

signal textureSelected( chosenTexture )

func setupScene( texture ):
	print(texture)
	set_normal_texture( texture )
	set_size( THUMB_SIZE )

func _on_pressed():
	emit_signal("textureSelected", get_normal_texture() )
