extends "res://Scripts/Enemies/flying_enemy_base.gd"

const APPROACH_SPEED = 200
const BACKING_SPEED = 250
const UP_SPEED = -300

const BACKING_DELTA_FACTOR = 2

@onready var shoot_timer = $ShootTimer
@onready var Bullet = preload("res://Scenes/Bullets/enemy_bullet.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	health = 800
	explosion_sprite = $ExplosionSprite
	sprite = $Sprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	super(delta)
	if destroyed:
		return
	match current_state:
		States.ROAM:
			roam_step(delta)
		States.CHASE:
			chase_step(delta)
	boids_separation(delta)
	move_and_slide()


func chase_step(delta):
	if weakref(player).get_ref():
		goal = player.global_position
		var distance = global_position.distance_to(goal)
		direction = (player.hitpoint() - global_position).normalized()
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
		if direction.x > 0:
			$Sprite.scale.x = -1
			$Sprite.rotation = direction.angle()
		else:
			$Sprite.scale.x = 1
			$Sprite.rotation = direction.angle() - PI


func shoot():
	var new_bullet = Bullet.instantiate()
	new_bullet.global_position = global_position
	new_bullet.prepare(direction)
	get_tree().get_root().add_child(new_bullet)


func destroy():
	super()
	set_collision_layer_value(2, false)


func _on_shoot_timer_timeout():
	shoot()

