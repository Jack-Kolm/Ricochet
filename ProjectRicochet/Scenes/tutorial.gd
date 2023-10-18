extends Node2D

var button_count = 0
var timer_count = 0


@export var player : Player

# Called when the node enters the scene tree for the first time.
func _ready():
	$SecondText.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_player(player):
	self.player = player


func _on_hurtbox_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	pass # Replace with function body.


func first_hit():
	$MiddleText.text = "Studsa kulorna din jävla idiot"
	$MiddleText.set_modulate(Color(1.0,0.3,0.3))
	$MiddleText.visible = true
	$Lamp4.enabled = true
	$Switch1/Sprite2D.set_modulate(Color(2.0, 0.5, 0.5))
	$Lamp1.enabled = false
	$SwitchTimer.start()
	$FirstText.visible = false
	$Lamp3.enabled = false
	$Lamp1.scale = Vector2(0.25, 0.25)
	button_count = 1


func second_hit():
	$MiddleText.text = "Kung"
	$MiddleText.set_modulate(Color(0.3,1.0,0.3))
	$MiddleText.visible = true
	$Lamp5.enabled = true
	$Switch2/Sprite2D.set_modulate(Color(0.5, 2.0, 0.5))
	$Lamp2.scale = Vector2(1.0, 1.0)
	timer_count = 1
	$SwitchTimer.start()


func warn_player():
	$MiddleText.text = "Skärp dig tönt"
	$MiddleText.set_modulate(Color(1.0,0.3,0.3))
	$MiddleText.visible = true
	$Lamp4.enabled = true
	$SwitchTimer.start()

func _on_switch_timer_timeout():
	$MiddleText.visible = false
	$Lamp4.enabled = false
	$Lamp5.enabled = false
	match timer_count:
		0:
			$Switch1.disable()
			$Switch2.enable()
			$Lamp2.enabled = true
			$SecondText.visible = true
		1:
			$Switch2.disable()
			$Lamp2.enabled = false
			$SecondText.visible = false
			$Walkway.visible = true
			$Walkway/CollisionShape2D.disabled = false
			




func _on_teleport_area_body_entered(body):
	var everything = get_tree().get_root().get_children()
	for child in everything:
		child.queue_free()
	#var my_bullets = get_tree().get_nodes_in_group("ricochet_bullets")
	#for bullet in my_bullets:
	#	bullet.queue_free()
	get_tree().change_scene_to_file("res://main_menu.tscn")
