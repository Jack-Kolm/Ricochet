extends StaticBody2D

@export var start_visible = true


# Called when the node enters the scene tree for the first time.
func _ready():
	if start_visible:
		enable()
	else:
		disable()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func enable():
	$Hurtbox.monitoring = true
	self.visible = true

func disable():
	$Hurtbox.monitoring = false
	self.visible = false


func _on_hurtbox_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	pass # Replace with function body.


func _on_hurtbox_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	pass # Replace with function body.


func _on_hurtbox_body_entered(body):
	var root_node = get_tree().get_root().get_child(0)
	if body.is_in_group("ricochet_bullets"):
		var count = root_node.button_count
		match count:
			0:
				root_node.first_hit()
			1:
				if body.get_bounces() > 0:
					root_node.second_hit()
					body.destroy()
				else:
					root_node.warn_player()

