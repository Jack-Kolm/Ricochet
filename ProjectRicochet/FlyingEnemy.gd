extends CharacterBody2D

enum States {ROAMING, CHASING}
var current_state = States.ROAMING

const APPROACH_SPEED = 200
const BACKING_SPEED = 250
const UP_SPEED = -300

const BACKING_DELTA_FACTOR = 2
const STATIONARY_DELTA_FACTOR = 5

var health = 800
var direction = Vector2(0,0)
var goal = Vector2(0,0)
var root_node = null
var player = null

@onready var shoot_timer = $ShootTimer
@onready var Bullet = preload("res://enemy_bullet.tscn")

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
		if direction.y < 0:
			velocity = lerp(velocity, Vector2(velocity.x, UP_SPEED), delta)
		if distance < 300:
			velocity = lerp(velocity, -direction * BACKING_SPEED, delta*BACKING_DELTA_FACTOR)
		elif distance < 400 and distance > 300:
			velocity = lerp(velocity, Vector2(0,0), delta*STATIONARY_DELTA_FACTOR)#Vector2(0,0)
		else:
			velocity = lerp(velocity, direction * APPROACH_SPEED, delta)
		
		if shoot_timer.is_stopped():
			shoot_timer.start()

func chase_step(delta):
	pass

func shoot():
	var new_bullet = Bullet.instantiate()
	new_bullet.global_position = self.global_position
	new_bullet.prepare(direction)
	get_tree().get_root().add_child(new_bullet)


func take_damage(damage):
	#hit_sound_player.stream = hit_sound
	#hit_sound_player.play()
	#bat_sprite.set_modulate(Color(2, 0.1, 0.1))
	self.health -= damage
	if self.health <= 0:
		self.destroy()


func apply_force(force, direction):
	velocity = Vector2(0,0)
	velocity += force * direction

func destroy():
	queue_free()

func _on_shoot_timer_timeout():
	shoot()
