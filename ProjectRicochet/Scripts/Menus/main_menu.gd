extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_button_up():
	Global.elevator_checkpoint = false
	SceneSwitcher.switch_scene(SceneSwitcher.Scenes.INITMAIN)
	#get_tree().reload_current_scene()


func _on_quit_button_button_up():
	get_tree().quit()


func _on_tutorial_button_button_up():
	SceneSwitcher.switch_scene(SceneSwitcher.Scenes.TUTORIAL)


func _on_extras_button_button_up():
	$MarginContainer/VBoxMain.visible = false
	$MarginContainer/VBoxExtras.visible = true


func _on_back_menu_button_up():
	$MarginContainer/VBoxMain.visible = true
	$MarginContainer/VBoxExtras.visible = false


func _on_boss_1_button_button_up():
	Global.second_boss_flag = false
	SceneSwitcher.switch_scene(SceneSwitcher.Scenes.BOSS)

func _on_boss_2_button_button_up():
	Global.second_boss_flag = true
	SceneSwitcher.switch_scene(SceneSwitcher.Scenes.BOSS)
