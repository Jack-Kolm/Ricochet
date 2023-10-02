extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -600.0

var health = 400
var friction_factor = 2000
var direction = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var destroyed = false
var should_stop = false

enum States {ROAMING, CHASING}
var current_state = States.ROAMING

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


# Called when the node enters the scene tree for the first time.
func _ready():
	var root_node = get_tree().get_root().get_child(0)
	player = root_node.player
	if weakref(player).get_ref():
		navigation_agent.set_target_position(player.global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if destroyed:
		return
	match current_state:
		States.ROAMING:
			standard_step(delta)
		States.CHASING:
			chase_step(delta)
	move_and_slide()


func chase_step(delta):
		
	self.sprite.set_modulate(Color(40, 0.5, 0.5))
	if not is_on_floor():
		# Add the gravity.
		velocity.y += gravity * delta
		# Fall / Jump
		sprite.animation = "jump"
	if direction:
		shield.position = Vector2(20*direction, 24) 
		wall_check_shape.position = Vector2(20*direction, 32)
		player_check_shape.position = Vector2(136*direction, 16)
		ledge_raycast.target_position = Vector2(33*direction, 80)
		sprite.scale.x = 2 * direction
	if is_on_floor():
		#if not ledge_raycast.is_colliding():
		#	velocity.x = move_toward(velocity.x, 0, delta*friction_factor)
		if direction:
			sprite.animation = "walk"
		else:
			sprite.animation = "idle"
	if weakref(player).get_ref():
		var dir_to_player = global_position.direction_to(player.global_position).x
		direction = sign(dir_to_player)
		if global_position.distance_to(player.global_position) > 500:
			current_state = States.ROAMING
		if should_stop:
			velocity.x = 0
		elif global_position.distance_to(player.global_position) < 50:
			velocity.x = move_toward(velocity.x, 0, delta*friction_factor)
		else:
			velocity.x = lerp(velocity.x, direction * SPEED, delta*5)


func standard_step(delta):
	self.sprite.set_modulate(Color(20, 1, 1))
	if not is_on_floor():
		# Add the gravity.
		velocity.y += gravity * delta
		# Fall / Jump
		sprite.animation = "jump"
	if direction:
		shield.position = Vector2(20*direction, 24) 
		wall_check_shape.position = Vector2(20*direction, 32)
		player_check_shape.position = Vector2(136*direction, 16)
		ledge_raycast.target_position = Vector2(33*direction, 80)
		sprite.scale.x = 2 * direction
		
	if is_on_floor():
		if should_stop:
			velocity.x = 0
		else:
			velocity.x = direction * SPEED * delta * 10
		if not ledge_raycast.is_colliding() and turn_around_timer.is_stopped():
			direction *= -1
			turn_around_timer.start()
		if not direction or velocity.x == 0:
			sprite.animation = "idle"
		else:
			sprite.animation = "walk"
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


func _input(event):
	if event.is_action_pressed("Crouch"):
		navigation_agent.set_target_position(player.global_position)


func take_damage(damage):
	#queue_free()
	self.health -= damage
	if self.health <= 0:
		destroy()


func apply_force(force, direction):
	print("FOOOORCE")
	velocity = Vector2(0,0)
	velocity += force * direction


func destroy():
	#hit_sound_player.stream = death_sound
	#hit_sound_player.play()
	destroyed = true
	self.set_collision_layer_value(1, false)
	self.set_collision_mask_value(1, false)
	sprite.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("default")


func _on_wall_check_body_entered(body):
	print(body.name)
	if body.is_in_group("terrain") or body.name == "TileMap":
		velocity.y = JUMP_VELOCITY


func _on_player_check_body_entered(body):
	print(body.name)
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

