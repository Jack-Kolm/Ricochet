extends CharacterBody2D

const SPEED = 600.0
const JUMP_VELOCITY = -600.0
const STOP_FACTOR = 2000
const MOVE_FACTOR = 200
const SIZE_SCALE = 1.2
const SPRITE_SCALE = 2

var health = 400
var friction_factor = 2000
var x_axis = -1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var destroyed = false
var should_stop = false

enum States {ROAMING, CHASING, HURT}
var current_state = States.ROAMING
var previous_state = null
var player = null

@onready var sprite = $EnemySprite
@onready var shield = $Shield
@onready var wall_check_shape = $WallCheck/Shape
@onready var navigation_agent = $NavigationAgent
@onready var player_check_shape = $PlayerCheck/Shape
@onready var ledge_raycast = $LedgeRaycast
@onready var turn_around_timer = $TurnAroundTimer
@onready var move_timer = $MoveTimer
@onready var explosion_sprite = $ExplosionSprite
@onready var attack_timer = $AttackTimer
@onready var knockback_timer = $KnockbackTimer
# Called when the node enters the scene tree for the first time.
func _ready():
	var root_node = get_tree().get_root().get_child(0)
	player = root_node.player
	if weakref(player).get_ref():
		navigation_agent.set_target_position(player.global_position)
	self.scale = Vector2(SIZE_SCALE, SIZE_SCALE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if destroyed:
		return
	match current_state:
		States.ROAMING:
			standard_step(delta)
		States.CHASING:
			chase_step(delta)
		States.HURT:
			hurt_step(delta)
	move_and_slide()

func hurt_step(delta):
	handle_sprite(delta)
	self.sprite.set_modulate(Color(40, 0.5, 0.5))
	velocity = lerp(velocity, Vector2(0,0), delta*2)

func chase_step(delta):
	handle_sprite(delta)
		#if not ledge_raycast.is_colliding():
		#	velocity.x = move_toward(velocity.x, 0, delta*friction_factor)
	if weakref(player).get_ref():
		var horizontal_dir_to_player = global_position.direction_to(player.global_position).x
		x_axis = sign(horizontal_dir_to_player)
		if global_position.distance_to(player.global_position) > 500:
			current_state = States.ROAMING
		if should_stop:
			velocity.x = 0
		elif global_position.distance_to(player.global_position) < 50:
			velocity.x = move_toward(velocity.x, 0.0, delta*STOP_FACTOR)
			if attack_timer.is_stopped:
				player.take_damage(10, Vector2(x_axis, 0)) #temporary!!
		else:
			velocity.x =  x_axis * SPEED * delta * 10


func standard_step(delta):
	self.sprite.set_modulate(Color(20, 1, 1))
	handle_sprite(delta)
		
	if is_on_floor():
		if should_stop:
			velocity.x = 0.0
		else:
			velocity.x =  x_axis * SPEED * delta * 10
		if not ledge_raycast.is_colliding() and turn_around_timer.is_stopped():
			turn_around()
	#if weakref(player).get_ref():
	#	var dir_to_player = global_position.direction_to(player.global_position).x
	"""
	if weakref(player).get_ref():
		#navigation_agent.set_target_position(player.global_position)
		#var dir_to_player = global_position.direction_to(player.global_position).x
		#direction = sign(dir_to_player)
	
	if not navigation_agent.is_navigation_finished():
		var movement_delta = SPEED * delta * 50
		var next_path_position = navigation_agent.get_next_path_position()
		var new_dir = self.global_position.direction_to(next_path_position).normalized()
		direction = sign(new_dir.x)
		velocity.x = direction * movement_delta
	
	"""
	#else:
	#velocity.x = move_toward(velocity.x, 0, delta*friction_factor)



func handle_sprite(delta):
	if not is_on_floor():
		# Add the gravity.
		velocity.y += gravity * delta
		# Fall / Jump
		sprite.animation = "jump"
	else:
		if velocity.x == 0:
			sprite.animation = "idle"
		else:
			sprite.animation = "walk"
	if x_axis:
		shield.position = Vector2(20*x_axis, 24) 
		wall_check_shape.position = Vector2(20*x_axis, 32)
		player_check_shape.position = Vector2(136*x_axis, 16)
		ledge_raycast.target_position = Vector2(33*x_axis, 80)
		sprite.scale = Vector2(x_axis * SPRITE_SCALE, SPRITE_SCALE)
		


func turn_around():
	x_axis *= -1
	turn_around_timer.start()


func _input(event):
	if event.is_action_pressed("Crouch"):
		navigation_agent.set_target_position(player.global_position)


func take_damage(damage):
	#queue_free()
	self.health -= damage
	if self.health <= 0:
		destroy()


func apply_force(force, direction):
	previous_state = current_state
	current_state = States.HURT
	knockback_timer.start()
	velocity = Vector2(0,0)
	self.friction_factor = 500
	if direction.x > 0:
		velocity += Vector2(400, -300)
	else:
		velocity += Vector2(-400, -300)


func destroy():
	#hit_sound_player.stream = death_sound
	#hit_sound_player.play()
	destroyed = true
	self.set_collision_layer_value(1, false)
	self.set_collision_mask_value(1, false)
	sprite.visible = false
	shield.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("default")


func _on_wall_check_body_entered(body):
	if body.is_in_group("terrain") or body.name == "TileMap":
		velocity.y = JUMP_VELOCITY


func _on_player_check_body_entered(body):
	if body.name == "Player":
		current_state = States.CHASING


func _on_turn_around_timer_timeout():
	ledge_raycast.enabled = true


func _on_explosion_sprite_animation_finished():
	explosion_sprite.visible = false
	queue_free()


func _on_move_timer_timeout():
	if should_stop == true:
		
		should_stop = false
	else:
		should_stop = true


func _on_shield_area_body_entered(body):
	#print(body.name)
	if body.is_in_group("ricochet_bullets"):
		var normal = Vector2(x_axis, 0)
		body.ricochet(normal)



func _on_hurtbox_body_entered(body):
	if body.is_in_group("ricochet_bullets"):
		self.take_damage(body.get_damage())
		self.apply_force(200, body.get_direction())
		
	pass # Replace with function body.


func _on_knockback_timer_timeout():
	current_state = previous_state
	pass # Replace with function body.
