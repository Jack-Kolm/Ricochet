extends Node2D

@onready var player
var menu_scene = preload("res://main_menu.tscn")
var restart_menu = null
# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = true
	restart_menu = menu_scene.instantiate()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func a_simple_test():
	print("HALLÅ!")

func set_player(player):
	self.player = player


func _on_game_area_body_exited(body):
	var enemies = get_tree().get_nodes_in_group("enemies")
	var bullets = get_tree().get_nodes_in_group("bullets")
	for enemy in enemies:
		enemy.queue_free()
	for bullet in bullets:
		bullet.queue_free()
	#self.visible = false
	#restart_menu.restart_flag = true
	#get_tree().change_scene_to_packed(menu_scene)
	get_tree().change_scene_to_file("res://main_menu.tscn")
