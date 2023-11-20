extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_button_up():
	SceneSwitcher.switch_scene(SceneSwitcher.Scenes.INITMAIN)
	#get_tree().reload_current_scene()


func _on_quit_button_button_up():
	get_tree().quit()
