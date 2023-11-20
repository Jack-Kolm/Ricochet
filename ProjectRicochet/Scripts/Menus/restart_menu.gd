extends Control

var current_level = null

var standard_level = preload("res://Scenes/Levels/init_main.tscn")
var boss_level = preload("res://Scenes/boss.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_button_up():
	#self.visible = false
	#AudioServer.set_bus_mute(1, true)
	#sAudioServer.set_bus_mute(2, true)
	if Global.boss_level_flag == false:
		SceneSwitcher.switch_scene(SceneSwitcher.Scenes.INITMAIN)
	else:
		SceneSwitcher.switch_scene(SceneSwitcher.Scenes.BOSS)


func _on_quit_to_menu_button_button_up():
		SceneSwitcher.switch_scene(SceneSwitcher.Scenes.MENU)
