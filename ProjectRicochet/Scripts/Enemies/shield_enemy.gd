extends CharacterBody2D

const SPEED = 200.0
const CHARGE_SPEED = 500.0
const JUMP_VELOCITY = -600.0
const LEDGE_VELOCITY = 100
const CHARGE_VELOCITY = 1000
const STOP_FACTOR = 1
const MOVE_FACTOR = 1
const CHARGE_FACTOR = 3
const KNOCKBACK_DELTA = 500
const DAMAGE_MODULATE_FACTOR = 2

const PLAYER_CHECK_SHAPE_Y = 46

const TOWARD_TARGET_DISTANCE = 500
const AWAY_TARGET_DISTANCE = 400

const KNOCKBACK_X = 300
const KNOCKBACK_Y = 300
const KNOCKBACK_PLAYER_FORCE = 500
const SIZE_SCALE = 2.5
const SPRITE_SCALE = 1

const DAMAGE = 100

var health = 400
@export var movement_x_axis = 1
var facing_x_axis = movement_x_axis
var player_x_axis = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var destroyed = false
var should_stop = false
var charging = false

enum States {ROAM, CHASE, HURT}
var current_state = States.ROAM
var previous_state = null
var player = null
@export var stationary = false
@export var player_check_shape_x = 52


@onready var sprite = $EnemySprite
@onready var shield = $Shield
@onready var wall_check = $WallCheck
@onready var navigation_agent = $NavigationAgent
@onready var player_check = $PlayerCheck
@onready var ledge_raycast = $LedgeRaycast
@onready var turn_around_timer = $TurnAroundTimer
@onready var move_timer = $MoveTimer
@onready var explosion_sprite = $ExplosionSprite
@onready var attack_timer = $AttackTimer
@onready var knockback_timer = $KnockbackTimer
@onready var turn_to_player_timer = $TurnToPlayerTimer
@onready var hitbox = $Hitbox
@onready var player_check_shape = $PlayerCheck/Shape

# Called when the node enters the scene tree for the first time.
func _ready():
	var root_node = get_tree().get_root().get_child(0)
	player = root_node.player
	if weakref(player).get_ref():
		navigation_agent.set_target_position(player.global_position)
	scale = Vector2(SIZE_SCALE, SIZE_SCALE)


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
		States.HURT:
			hurt_step(delta)
	move_and_slide()


func hurt_step(delta):
	general_step(delta)
	velocity.x = move_toward(velocity.x, 0.0, delta*KNOCKBACK_DELTA)

func charge_step():
	pass

func enter_chase():
	facing_x_axis = player_x_axis
	current_state = States.CHASE
	stationary = false
	
func chase_step(delta):
	general_step(delta)
	if weakref(player).get_ref():
		movement_x_axis = player_x_axis
		if turn_to_player_timer.is_stopped():
			if player_x_axis * facing_x_axis != 1:
				turn_to_player_timer.start()
			if not charging:
				var target_distance = global_position.distance_to(player.global_position)
				if target_distance < AWAY_TARGET_DISTANCE:
					velocity.x =  lerp(velocity.x, movement_x_axis * -SPEED, delta * MOVE_FACTOR)
					if $ChargeTimeout.is_stopped():
						charging = true
						$ChargeTimeout.start()
						$ChargeDuration.start()
				elif target_distance > AWAY_TARGET_DISTANCE and target_distance < TOWARD_TARGET_DISTANCE:
					velocity.x = lerp(velocity.x, 0.0, delta*STOP_FACTOR)

				else:
					velocity.x =  lerp(velocity.x, movement_x_axis * SPEED, delta * MOVE_FACTOR)
			else:
				velocity.x =  lerp(velocity.x, facing_x_axis*CHARGE_SPEED, delta * CHARGE_FACTOR)

func roam_step(delta):
	facing_x_axis = movement_x_axis
	general_step(delta)
	if is_on_floor():
		if should_stop or stationary:
			velocity.x = lerp(velocity.x, 0.0, delta*STOP_FACTOR)
		else:
			velocity.x =  move_toward(velocity.x, movement_x_axis * SPEED, delta * MOVE_FACTOR)


func general_step(delta):
	sprite.set_modulate(lerp(sprite.get_modulate(), Color(2,1,1), delta*DAMAGE_MODULATE_FACTOR))
	player_x_axis = sign(global_position.direction_to(player.global_position).x)
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
	if facing_x_axis:
		#scale.x = SIZE_SCALE * facing_x_axis
		shield.scale.x = facing_x_axis
		wall_check.scale.x = facing_x_axis
		player_check.scale.x = facing_x_axis
		sprite.scale.x = facing_x_axis
		hitbox.scale.x = facing_x_axis

func turn_around():
	if turn_around_timer.is_stopped() and turn_to_player_timer.is_stopped():
		movement_x_axis *= -1
		turn_around_timer.start()


func _input(event):
	if event.is_action_pressed("Crouch"):
		navigation_agent.set_target_position(player.global_position)


func apply_damage(damage):
	#queue_free()
	sprite.set_modulate(Color(40, 0.5, 0.5))
	health -= damage
	if health <= 0:
		destroy()


func apply_knockback(force, direction):
	previous_state = current_state
	current_state = States.HURT
	knockback_timer.start()
	velocity = Vector2(KNOCKBACK_X*sign(direction.x), -KNOCKBACK_Y)


func destroy():
	#hit_sound_player.stream = death_sound
	#hit_sound_player.play()
	destroyed = true
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	sprite.visible = false
	shield.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("default")


func jump():
	velocity.y = JUMP_VELOCITY


func _on_wall_check_body_entered(body):
	movement_x_axis *= -1


func _on_player_check_body_entered(body):
	if body.is_in_group("player"):
		enter_chase()



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
	if body.is_in_group("ricochet_bullets"):
		var bullet = body
		var normal = Vector2(facing_x_axis, 0)
		bullet.ricochet(normal)
		var correct_bounces = bullet.get_bounces()-1
		if correct_bounces > 0:
			velocity.x = correct_bounces * 100 * -facing_x_axis
		enter_chase()


func _on_hurtbox_body_entered(body):
	if body.is_in_group("ricochet_bullets"):
		enter_chase()
		apply_damage(body.get_damage())
		apply_knockback(200, body.get_direction())


func _on_knockback_timer_timeout():
	current_state = previous_state


func _on_turn_to_player_timer_timeout():
	if player_x_axis * facing_x_axis != 1:
		facing_x_axis = player_x_axis


func _on_ledge_check_body_exited(body):
	match current_state:
		States.ROAM:
			velocity.x = 0
			movement_x_axis *= -1
		States.CHASE:
			velocity.x =  LEDGE_VELOCITY * -movement_x_axis
	if current_state != States.HURT:
		pass



func _on_ledge_check_left_body_exited(body):
	match current_state:
		States.ROAM:
			velocity.x = LEDGE_VELOCITY
			movement_x_axis *= -1
		States.CHASE:
			velocity.x = LEDGE_VELOCITY



func _on_ledge_check_right_body_exited(body):
	match current_state:
		States.ROAM:
			velocity.x = -LEDGE_VELOCITY
			movement_x_axis *= -1
		States.CHASE:
			velocity.x = -LEDGE_VELOCITY



func _on_chase_area_body_exited(body):
	if body.is_in_group("player"):
		current_state = States.ROAM


func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		var player = body
		player.apply_damage(DAMAGE)
		player.apply_knockback(Vector2(player_x_axis, 0), KNOCKBACK_PLAYER_FORCE)

func _on_charge_duration_timeout():
#velocity.x = 1000 * facing_x_axis
	charging = false
	#pass 
