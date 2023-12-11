extends Control

var scene_to_enter
var should_play_music = true
# Called when the node enters the scene tree for the first time.
func _ready():
	$CenterContainer.visible = false
	Global.player_health = Global.PLAYER_MAX_HEALTH


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if should_play_music and not $BGMusic.is_playing():
		$BGMusic.play()


func enter_game():
	$StartSound.play()
	$Fader.activate()
	$MarginContainer.visible = false
	$CenterContainer.visible = true
	$BGMusic.stop()
	$PortraitFader.visible = false
	should_play_music = false
	await $Fader.finished

func _on_start_button_button_up():

	Global.elevator_checkpoint = false
	scene_to_enter = SceneSwitcher.Scenes.INITMAIN
	enter_game()


func _on_quit_button_button_up():
	get_tree().quit()


func _on_tutorial_button_button_up():
	Global.elevator_checkpoint = false
	scene_to_enter = SceneSwitcher.Scenes.TUTORIAL
	enter_game()


func _on_extras_button_button_up():
	$MarginContainer/VBoxMain.visible = false
	$MarginContainer/VBoxExtras.visible = true


func _on_back_menu_button_up():
	$MarginContainer/VBoxMain.visible = true
	$MarginContainer/VBoxExtras.visible = false
	$MarginContainer/VBoxStartGame.visible = false

func _on_open_menu_button_button_up():
	$MarginContainer/VBoxMain.visible = false
	$MarginContainer/VBoxStartGame.visible = true

func _on_boss_1_button_button_up():
	Global.second_boss_flag = false
	scene_to_enter = SceneSwitcher.Scenes.BOSS
	enter_game()

func _on_boss_2_button_button_up():
	Global.second_boss_flag = true

	scene_to_enter = SceneSwitcher.Scenes.BOSS
	enter_game()


func _on_fader_finished():
	SceneSwitcher.switch_scene(scene_to_enter)




