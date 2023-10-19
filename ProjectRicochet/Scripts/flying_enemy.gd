extends CharacterBody2D

enum States {ROAM, CHASE}
var current_state = States.ROAM

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
var destroyed = false
@onready var shoot_timer = $ShootTimer
@onready var Bullet = preload("res://Scenes/Enemies/enemy_bullet.tscn")
@onready var sprite = $Sprite
@onready var explosion_sprite = $ExplosionSprite
@onready var separation_area = $SeparationArea

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("enemies")
	root_node = get_tree().get_root().get_child(0)
	player = root_node.player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if destroyed:
		return
	match current_state:
		States.ROAM:
			roam_step(delta)
		States.CHASE:
			chase_step(delta)
	boids_separation(delta)
	move_and_slide()


func roam_step(delta):
	velocity = lerp(velocity, Vector2(0,0), delta*STATIONARY_DELTA_FACTOR)#Vector2(0,0)


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


func boids_separation(delta):

	var separation_distance = 1000
	var separation_factor = 1
	var delta_factor = 1
	var separation_dx = 0.0
	var separation_dy = 0.0
	var should_separate = false
	for body in separation_area.get_overlapping_bodies():
		if body.is_in_group("enemies") and body != self:
			#if global_position.distance_to(body.global_position) < separation_distance:
			should_separate = true
			separation_dx += global_position.x - body.global_position.x
			separation_dy += global_position.y - body.global_position.y
	#global_position.x += separation_dx*separation_factor*delta
	#global_position.y += separation_dy*separation_factor*delta
	#velocity.x += separation_dx*separation_factor*delta
	#velocity.y += separation_dy*separation_factor*delta
	if should_separate:
		velocity.x = lerp(velocity.x, separation_dx*separation_factor, delta*delta_factor)
		velocity.y = lerp(velocity.y, separation_dy*separation_factor, delta*delta_factor)

func shoot():
	var new_bullet = Bullet.instantiate()
	new_bullet.global_position = global_position
	new_bullet.prepare(direction)
	get_tree().get_root().add_child(new_bullet)


func apply_damage(damage):
	#hit_sound_player.stream = hit_sound
	#hit_sound_player.play()
	#bat_sprite.set_modulate(Color(2, 0.1, 0.1))
	health -= damage
	if health <= 0:
		destroy()


func apply_knockback(force, direction):
	velocity = Vector2(0,0)
	velocity += force * direction


func destroy():
	set_collision_layer_value(2, false)
	destroyed = true
	sprite.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("default")


func _on_shoot_timer_timeout():
	shoot()


func _on_explosion_sprite_animation_finished():
	explosion_sprite.visible = false
	queue_free()


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		current_state = States.CHASE

