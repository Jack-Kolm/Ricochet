extends Area2D

@onready var bullet_cast = $BulletCast
@onready var timer = $DestructionTimer

@onready var speed = 0
@onready var direction = Vector2(0,0)
@onready var player = null
@onready var points = []

@onready var next_point = false
@onready var goal = null
var bounces = 0
var max_bounces = null

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if next_point and points.is_empty() == false:
		goal = points.pop_front()
		direction = global_position.direction_to(goal)
		next_point = false
	
	if global_position.distance_to(goal) < 15:
		bounces += 1
		speed += 1
		if bounces >= max_bounces:
			queue_free()
		next_point = true
	
	global_position += (direction * speed) #+ Vector2(10,0) 
	rotation = direction.angle() - (PI/2)


func prepare_bullet(new_speed, travel_points, start_spot):
	self.speed = new_speed
	self.points = travel_points
	self.max_bounces = travel_points.size()
	self.goal = self.points.pop_front()
	self.direction = start_spot.direction_to(self.goal)
	self.next_point = false


func _on_destruction_timer_timeout():
	queue_free()

