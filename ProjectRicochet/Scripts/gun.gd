extends StaticBody2D

@onready var raycast = $GunRayCast
@onready var tip_box = $GunTipBox

# Called when the node enters the scene tree for the first time.
func _ready():
	#raycast.global_position = self.global_position;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(get_global_mouse_position())
	self.rotation = self.rotation - (PI/2)
	#raycast.rotation = self.rotation

func get_raycast():
	return raycast

func is_tip_colliding():
	if raycast.is_colliding():
		return true
	else:
		return false

func get_tip_global_position():
	return tip_box.global_position
