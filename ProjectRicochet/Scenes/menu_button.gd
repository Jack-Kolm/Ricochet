extends Button

var icon_standard : CompressedTexture2D = load("res://Sprites/Bullets/NewBullets/NewBullet1.png")
var icon_focus : CompressedTexture2D = load("res://Sprites/Bullets/NewBullets/NewBullet3.png")
var icon_press : CompressedTexture2D = load("res://Sprites/Bullets/NewBullets/NewBullet6.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.icon = icon_standard


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_focus_entered():
	self.icon = icon_focus


func _on_focus_exited():
	self.icon = icon_standard


func _on_button_up():
	self.icon = icon_press
