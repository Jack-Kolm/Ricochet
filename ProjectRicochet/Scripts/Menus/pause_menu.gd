extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func enable():
	get_tree().paused = true
	$CanvasLayer.visible = true

func _on_resume_button_button_up():
	$CanvasLayer.visible = false
	get_tree().paused = false

func _on_menu_quit_button_button_up():
	get_tree().paused = false
	SceneSwitcher.switch_scene(SceneSwitcher.Scenes.MENU)
