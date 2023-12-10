extends Control


func _on_button_button_up():
	if Global.boss_level_flag or Global.second_boss_flag:
		SceneSwitcher.switch_scene(SceneSwitcher.Scenes.BOSS)
	else:
		SceneSwitcher.switch_scene(SceneSwitcher.Scenes.INITMAIN)

func _on_quit_to_menu_button_button_up():
		SceneSwitcher.switch_scene(SceneSwitcher.Scenes.MENU)
