extends PopupPanel

const RECENT_LIMIT = 20

var texturePreviewButton = preload("res://Components/Preview.tscn")

onready var textureBase = {
	"recent" : $VBox/Recent ,
	"path" : $VBox/Path
}

onready var pathDisplay = $VBox/TopBar/PathLabel
onready var trayDisplay = $VBox/Label

onready var fileDialog = $FileDialog

# Intermediate values
var trayNode

signal newTextureSelected( chosenTexture , trayNode )

func updateUI( filePath , _recentTextures, newTrayNode):
	# Store this node so we can send it back once we are done.
	trayNode = newTrayNode
	
	# Setup cosmetic displays
	var scopeFragment = "Global" if trayNode.isGlobal else "Local"
	var faceFragment = ""
	match trayNode.facingId:
		TextureTray.DRAWING_FACES.TOP:
			faceFragment = "Top"
		TextureTray.DRAWING_FACES.LEFT:
			faceFragment = "Left"
		TextureTray.DRAWING_FACES.RIGHT:
			faceFragment = "Right"
	
	var typeFragment = ""
	match trayNode.texType:
		TextureTray.TEXTURE_TYPE.NORMAL:
			typeFragment = "Texture"
		TextureTray.TEXTURE_TYPE.BASIC:
			typeFragment = "Normal"

	trayDisplay.set_text( scopeFragment + " " + faceFragment + " " + typeFragment )
	pathDisplay.set_text("Files in path " + filePath )

	# Load recent textures
	for child in textureBase.recent.get_children():
		queue_free()

	
	# Load any and all selected textures
	for child in textureBase.path.get_children():
		queue_free()
	
	var files = listFilesInDirectory( filePath )
	for file in files:
		

		var image = Image.new()
		var err = image.load(filePath + "/" + file )
		if err == OK:
			var texture = ImageTexture.new()
			texture.create_from_image(image, 0)
			var newButton = texturePreviewButton.instance()
			textureBase.path.add_child( newButton )
			newButton.setupScene( texture )
			newButton.connect("textureSelected" , self, "_on_textureSelected" )

	# Load and connect all textures from path.

func _on_textureSelected(chosenTexture):
	emit_signal( "newTextureSelected" , chosenTexture , trayNode )


func _on_ChangePath_pressed():
	pass # Replace with function body.