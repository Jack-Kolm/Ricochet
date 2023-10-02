extends CharacterBody2D

enum States {ROAMING, CHASING}
var current_state = States.ROAMING

var speed = 300
var health = 800
var direction = Vector2(0,0)
var goal = Vector2(0,0)
var root_node = null
var player = null


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("enemies")
	root_node = get_tree().get_root().get_child(0)
	player = root_node.player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match current_state:
		States.ROAMING:
			standard_step(delta)
		States.CHASING:
			chase_step(delta)
	move_and_slide()


func standard_step(delta):
	if weakref(player).get_ref():
		goal = player.global_position
		var distance = self.global_position.distance_to(goal)
		direction = (player.global_position - self.global_position).normalized()
		#global_position += (dir * 10)
		if distance < 300:
			velocity = lerp(velocity, -direction * speed, delta)
		elif distance < 400 and distance > 300:
			velocity = lerp(velocity, Vector2(0,0), delta*5)#Vector2(0,0)
		else:
			velocity = lerp(velocity, direction * speed, delta)


func chase_step(delta):
	pass

