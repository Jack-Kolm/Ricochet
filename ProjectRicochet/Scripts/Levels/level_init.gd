extends Node2D

class_name LevelInit

@export var player : Player

var menu_scene = preload("res://Scenes/Menus/main_menu.tscn")
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

