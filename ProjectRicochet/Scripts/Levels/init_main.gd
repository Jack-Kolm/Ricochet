extends Node2D

class_name InitMain

var first_fight = true
var zoom_out_count = 0
var elevator = false

const CLOSE_ZOOM = 4.7
const NORMAL_ZOOM = 3
const FAR_ZOOM = 1.6

@export var player : Player

var menu_scene = preload("res://Scenes/Menus/main_menu.tscn")
var boss_scene = preload("res://Scenes/boss.tscn")
var restart_scene = preload("res://Scenes/Menus/restart_menu.tscn")
var restart_menu = null

# Called when the node enters the scene tree for the first time.
func _ready():
	#super()
	self.visible = true
	self.player.change_camera_zoom(NORMAL_ZOOM)
	restart_menu = restart_scene.instantiate()

func _process(delta):
	if elevator:
		$Walls/Elevator.global_position.y += 50 * delta
		if $Walls/Elevator.global_position.y > -500:
			elevator = false

func _on_game_area_body_exited(body):
	if body.name == "Player":
		"""
		var enemies = get_tree().get_nodes_in_group("enemies")
		var bullets = get_tree().get_nodes_in_group("bullets")
		for enemy in enemies:
			enemy.queue_free()
		for bullet in bullets:
			bullet.queue_free()
		
		var everything = get_tree().get_root().get_children()
		for child in everything:
			child.queue_free()
		
		#self.visible = false
		#restart_menu.restart_flag = true
		#get_tree().change_scene_to_packed(menu_scene)
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn)
		"""
		var node_children = get_tree().get_root().get_children()
		goto_menu(node_children)


func goto_restart_menu():
	"""var node_children = get_tree().get_root().get_children()

	var enemies = get_tree().get_nodes_in_group("enemies")
	var bullets = get_tree().get_nodes_in_group("bullets")
	for enemy in enemies:
		enemy.queue_free()
	for bullet in bullets:
		bullet.queue_free()
	Global.current_level_name = get_tree().current_scene.name
	get_tree().change_scene_to_packed(restart_scene)"""
	#SceneSwitcher.switch_scene("res://Scenes/Menus/restart_menu.tscn")
	pass

func boss_door_activate():
	var node_children = get_tree().get_root().get_children()
	goto_boss(node_children)


func set_player(player):
	self.player = player


func get_player():
	return player


func goto_menu(children):
	for child in children:
		child.queue_free()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func goto_end(children):
	for child in children:
		#if not child.is_in_group("player"):
		child.queue_free()
	get_tree().change_scene_to_file("res://Scenes/end.tscn")

func goto_boss(children):
	for child in children:
		#if not child.is_in_group("player"):
		child.queue_free()
	get_tree().change_scene_to_file("res://Scenes/boss.tscn")


func cleanup():
	var children = get_tree().get_root().get_children()
	var level_children 
	for child in children:
		if child.name == "InitMain":
			level_children = child.get_children()
		elif child.is_in_group("enemies"):
			child.queue_free()
	
	for child in level_children:
		#print(child.name)
		child.queue_free()


func reload_self():
	#print("YOOO")
	cleanup()
	get_tree().reload_current_scene()

func _on_zoom_area_5_entered():
	elevator = true
	pass # Replace with function body.


func _on_spawner_1_completed():
	$Walls/WallLock1.unlock()
	player.change_camera_zoom(CLOSE_ZOOM, 0.5)
	pass # Replace with function body.


func _on_spawner_2_completed():
	$Walls/WallLock2.unlock()
	$Graffiti/Arrow3.visible = true
	#$AmbiencePlayer.play()
	#$MusicPlayer.stop()
	player.change_camera_zoom(NORMAL_ZOOM, 0.5)


func _on_fall_area_body_entered(body):
	if body.is_in_group("player"):
		var node_children = get_tree().get_root().get_children()
		goto_menu(node_children)
