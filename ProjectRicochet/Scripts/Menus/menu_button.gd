extends Button

var icon_standard : CompressedTexture2D = load("res://Sprites/Bullets/NewBullets/NewBullet1.png")
var icon_focus : CompressedTexture2D = load("res://Sprites/Bullets/NewBullets/NewBullet3.png")
var icon_press : CompressedTexture2D = load("res://Sprites/Bullets/NewBullets/NewBullet6.png")
var is_being_pressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.icon = icon_standard


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not is_being_pressed:
		if self.is_hovered():
			self.icon = icon_focus
		else:
			self.icon = icon_standard

func _on_focus_entered():
	self.icon = icon_focus


func _on_focus_exited():
	self.icon = icon_press


func _on_button_up():
	self.icon = icon_press
	$ClickSound.play()
	is_being_pressed = false


func _on_button_down():
	self.icon = icon_press
	is_being_pressed = true

