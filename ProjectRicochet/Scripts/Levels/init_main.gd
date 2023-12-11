extends Node2D

class_name InitMain

var first_fight = true
var zoom_out_count = 0
var elevator = false

const CLOSE_ZOOM = 4.7
const NORMAL_ZOOM = 3.0
const FAR_ZOOM = 1.6

@export var player : Player

var menu_scene = preload("res://Scenes/Menus/main_menu.tscn")
var boss_scene = preload("res://Scenes/Levels/boss_level.tscn")
var restart_scene = preload("res://Scenes/Menus/restart_menu.tscn")
var restart_menu = null

var boss_door_unlock_count = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	#super()
	self.visible = true
	self.player.change_camera_zoom(NORMAL_ZOOM)
	restart_menu = restart_scene.instantiate()
	Global.boss_level_flag = false
	Global.second_boss_flag = false
	if Global.elevator_checkpoint:
		$Enemies/ElevatorShieldEnemy.queue_free()
		player.global_position = $Checkpoint.global_position
		$Checkpoint.set_as_active()

func _process(delta):
	if elevator:
		if not $Walls/Elevator/ElevatorGoing.is_playing():
			$Walls/Elevator/ElevatorGoing.play()
		$Walls/Elevator.global_position.y += 50 * delta
		if $Walls/Elevator.global_position.y > -500:
			$Walls/Elevator/ElevatorGoing.stop()
			$Walls/Elevator/ElevatorEnd.play()
			elevator = false


func boss_door_activate():
	SceneSwitcher.switch_scene(SceneSwitcher.Scenes.BOSS)


func set_player(new_player):
	self.player = new_player


func get_player():
	return player


func cleanup():
	var children = get_tree().get_root().get_children()
	for child in children:
		if child.is_in_group("enemies"):
			child.queue_free()
	for child in get_children():
		if child.is_in_group("enemies") or child.is_in_group("bullets"):
			child.queue_free()

func reload_self():
	cleanup()
	get_tree().reload_current_scene()

func unlock_boss_door():
	boss_door_unlock_count =  boss_door_unlock_count - 1
	print(boss_door_unlock_count)
	if boss_door_unlock_count < 1:
		$Walls/WallLock3.unlock()

func _on_spawner_1_completed():
	$Walls/WallLock1.unlock()
	player.change_camera_zoom(CLOSE_ZOOM, 0.5)


func _on_spawner_2_completed():
	$Walls/WallLock2.unlock()
	$Graffiti/Arrow3.visible = true
	player.change_camera_zoom(NORMAL_ZOOM, 0.5)


func _on_fall_area_body_entered(body):
	if body.is_in_group("player"):
		cleanup()
		body.destroy()
	elif body.is_in_group("enemies"):
		body.destroy()


func _on_spawner_8_completed():
	$Walls/Elevator/ElevatorStart.play()


func _on_elevator_start_finished():
	elevator = true


func _on_elevator_spawner_1_completed():
	pass

func _on_elevator_spawner_2_completed():
	pass

func _on_elevator_spawner_3_completed():
	pass

func _on_elevator_spawner_4_completed():
	pass

func _on_elevator_end_finished():
	$Walls/WallLock3.unlock()


func _on_checkpoint_activated():
	Global.elevator_checkpoint = true
