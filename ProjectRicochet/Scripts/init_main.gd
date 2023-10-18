extends Node2D

@export var player : Player

var menu_scene = preload("res://Scenes/main_menu.tscn")
var restart_menu = null


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = true
	restart_menu = menu_scene.instantiate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func a_simple_test():
	print("HALLÅ!")


func set_player(player):
	self.player = player


func _on_game_area_body_exited(body):
	if body.name == "Player":
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
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

