extends LevelInit


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	self.visible = true
	self.player.change_camera_zoom(0.75)


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


func _on_zoom_in_area_body_exited(body):
	player.change_camera_zoom(1, 2)
	$AmbiencePlayer.stop()
	$MusicPlayer.play()
	pass # Replace with function body.


func _on_spawner_completed():
	$Walls/Wall.queue_free()

