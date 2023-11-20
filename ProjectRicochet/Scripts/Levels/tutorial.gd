extends Node2D

var button_count = 0
var timer_count = 0

var button_hit = false

@export var player : Player


func _ready():
	player.change_camera_zoom(2.2, 4)


func set_player(player):
	self.player = player


func good_hit():
	$MiddleText.text = "✓"
	$MiddleText.set_modulate(Color(0.3,1.0,0.3))
	$MiddleText.visible = true
	$MiddleTextLamp.enabled = true
	$Switch1/Sprite2D.set_modulate(Color(0.5, 2.0, 0.5))
	$Lamp1.enabled = false
	$Lamp3.enabled = true
	button_hit = true
	$SwitchTimer.start()

func bad_hit():
	$MiddleText.text = "✗"
	$MiddleText.set_modulate(Color(1.0,0.3,0.3))
	$MiddleText.visible = true
	$MiddleTextLamp.enabled = true
	$Switch1/Sprite2D.set_modulate(Color(2.0, 0.5, 0.5))
	$Lamp1.enabled = false
	$Lamp2.enabled = true
	$SwitchTimer.start()

func _on_switch_timer_timeout():
	if button_hit:
		$MiddleText.visible = false
		$MiddleTextLamp.enabled = false
		$Lamp3.enabled = false
		$Switch1/Arrows.visible = false
		$Switch1/Label.visible = false
		$GuidingArrows.visible = false
		$Lamp4.enabled = false
		$Instructions/Last.visible = true
		$WallLock.unlock()
	else:
		$MiddleText.visible = false
		$MiddleTextLamp.enabled = false
		$Switch1/Sprite2D.set_modulate(Color(1, 1, 1))
		$Lamp1.enabled = true
		$Lamp2.enabled = false




func _on_teleport_area_body_entered(body):
	return
	var everything = get_tree().get_root().get_children()
	for child in everything:
		child.queue_free()
	#var my_bullets = get_tree().get_nodes_in_group("ricochet_bullets")
	#for bullet in my_bullets:
	#	bullet.queue_free()
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

