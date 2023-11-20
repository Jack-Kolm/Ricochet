extends Node2D

class_name LevelInit

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
	
	restart_menu = menu_scene.instantiate()


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
		child.queue_free()


func reload_self():
	cleanup()
	get_tree().reload_current_scene()
	$CanvasLayer/RestartMenu.visible = false
