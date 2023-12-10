extends Line2D

@export var max_length = 30
var point = Vector2()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = Vector2(0,0)
	global_rotation = 0
	point = get_parent().global_position
	add_point(point)
	while get_point_count() > max_length:
		remove_point(0)

