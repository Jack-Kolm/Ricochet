extends "res://Scripts/Enemies/base_enemy.gd"

class_name ShieldEnemyBase

const SPEED = 50.0
const CHARGE_SPEED = 400.0
const JUMP_VELOCITY = -200.0
const LEDGE_VELOCITY = 100
const CHARGE_VELOCITY = 800
const STOP_FACTOR = 1
const MOVE_FACTOR = 2
const CHARGE_FACTOR = 4
const KNOCKBACK_DELTA = 400
const DAMAGE_MODULATE_FACTOR = 2


const STOP_CHASE_X = 2000
const STOP_CHASE_Y = 600

const SELF_KNOCKBACK_X = 100
const SELF_KNOCKBACK_Y = 100
const KNOCKBACK_PLAYER_FORCE = 300

const SPRITE_SCALE = 1.2
const REGULAR_MODULATE = Color(255,177,177)
const DEATH_MODULATE = Color(1,0.2,0.2)

@export var stationary = false

@export var size_scale : float = 1.3
var detect_player_x = 800
var chase_target_scale = 1
var toward_target_distance = 100
var away_target_distance = 150
@export var face_right_at_start = true
@export var has_shield : bool = false

var detect_player_y = 400

enum States {ROAM, CHASE, HURT, DESTROYED}

var current_state = States.ROAM
var previous_state = null

var damage

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var should_stop = false
var charging = false
var movement_x_axis = 1
var facing_x_axis = movement_x_axis
var player_x_axis = 1


@onready var shield = $Shield
@onready var wall_check = $WallCheck
@onready var navigation_agent = $NavigationAgent
@onready var player_check = $PlayerCheck
#@onready var ledge_raycast = $LedgeRaycast
@onready var turn_around_timer = $TurnAroundTimer
@onready var move_timer = $MoveTimer
@onready var attack_timer = $AttackTimer
@onready var knockback_timer = $KnockbackTimer
@onready var turn_to_player_timer = $TurnToPlayerTimer
@onready var player_check_shape = $PlayerCheck/Shape

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	if has_shield:
		$Shield/ShieldArea.monitoring = true
		$Shield/ShieldArea/Shape.disabled = false
		$Shield.visible = true
		health = 100
	else:
		health = 200
	if weakref(player).get_ref():
		navigation_agent.set_target_position(player.global_position)
	self.scale.x = size_scale
	self.scale.y = size_scale
	if face_right_at_start:
		facing_x_axis = 1
		movement_x_axis = 1
	else:
		facing_x_axis = -1
		movement_x_axis = -1
	$ChaseArea.scale = Vector2(chase_target_scale, chase_target_scale)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	super(delta)
	if destroyed and current_state != States.DESTROYED:
		enter_state(States.DESTROYED)
	match current_state:
		States.ROAM:
			roam_step(delta)
		States.CHASE:
			chase_step(delta)
		States.HURT:
			hurt_step(delta)
		States.DESTROYED:
			death_step(delta)
	move_and_slide()


# Called no matter state
func general_step(delta):
	super(delta)
	if weakref(player).get_ref():
		player_x_axis = sign(global_position.direction_to(player.global_position).x)
	if not is_on_floor():
		# Add the gravity.
		velocity.y += gravity * delta
		# Fall / Jump
		sprite.animation = "jump"
	else:
		if velocity.x == 0:
			$WalkSound.stop()
			sprite.animation = "idle"
		else:
			if $WalkSound.playing == false:
				$WalkSound.play()
			sprite.animation = "walk"
	if facing_x_axis:
		shield.scale.x = facing_x_axis
		wall_check.scale.x = facing_x_axis
		player_check.scale.x = facing_x_axis
		sprite.scale.x = facing_x_axis



func roam_step(delta):
	facing_x_axis = movement_x_axis
	general_step(delta)
	if is_on_floor():
		if should_stop or stationary:
			#velocity.x = lerp(velocity.x, 0.0, delta*STOP_FACTOR)
			velocity.x = 0
		else:
			#velocity.x =  move_toward(velocity.x, movement_x_axis * SPEED, delta * MOVE_FACTOR)
			velocity.x  = movement_x_axis * SPEED

func hurt_step(delta):
	general_step(delta)
	velocity.x = move_toward(velocity.x, 0.0, delta*KNOCKBACK_DELTA)

func death_step(delta):
	super(delta)
	if not exploding:
		if not is_on_floor():
			velocity.y += gravity * delta
		velocity.x = lerp(velocity.x, 0.0, delta*death_delta)

func chase_step(delta):
	pass


func enter_state(state):
	exit_state(current_state)
	match state:
		States.CHASE:
			facing_x_axis = player_x_axis
			stationary = false
		States.DESTROYED:
			sprite.play("death")
			sprite.modulate = DEATH_MODULATE
	current_state = state


func exit_state(state):
	match state:
		States.HURT:
			pass
		_:
			previous_state = state


func detect_player():
	var target_x = player.global_position.x - global_position.x
	var target_y = player.global_position.y - global_position.y
	if target_x*facing_x_axis < 0 and abs(target_x) < detect_player_x and abs(target_y) < detect_player_y:
		enter_state(States.CHASE)

func aggro():
	enter_state(States.CHASE)

func turn_around():
	if turn_around_timer.is_stopped() and turn_to_player_timer.is_stopped():
		movement_x_axis *= -1
		turn_around_timer.start()


func apply_damage(damage):
	super(damage)
	enter_state(States.HURT)
	


func apply_knockback(force, direction):
	knockback_timer.start()
	velocity = Vector2(SELF_KNOCKBACK_X*sign(direction.x), -SELF_KNOCKBACK_Y)
	


func destroy():
	#hit_sound_player.stream = death_sound
	#hit_sound_player.play()
	super()
	shield.visible = false
	set_collision_mask_value(3, true)
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	$Hitbox.monitoring = false



func jump():
	velocity.y = JUMP_VELOCITY


func _on_wall_check_body_entered(body):
	#if body.is_in_group("enemies"):
	#	var dir_switch = sign(global_position.direction_to(body.global_position).x)
	#	self.velocity.x = LEDGE_VELOCITY * -dir_switch
	#else:
	movement_x_axis *= -1


func _on_player_check_body_entered(body):
	if body.is_in_group("player"):
		enter_state(States.CHASE)


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
		enter_state(States.CHASE)




func _on_knockback_timer_timeout():
	current_state = previous_state


func _on_turn_to_player_timer_timeout():
	if player_x_axis * facing_x_axis != 1:
		facing_x_axis = player_x_axis


func _on_ledge_check_body_exited(body):
	match current_state:
		States.ROAM:
			velocity.x = 0
			turn_around()
		States.CHASE:
			velocity.x =  LEDGE_VELOCITY * -movement_x_axis
	if current_state != States.HURT:
		pass



func _on_ledge_check_left_body_exited(body):
	if $LedgeCheckLeft.has_overlapping_bodies():
		return
	match current_state:
		States.ROAM:
			velocity.x = LEDGE_VELOCITY
			turn_around()
		States.CHASE:
			self.velocity.y = -200
			self.velocity.x = LEDGE_VELOCITY
			#movement_x_axis *= -1
			charging = false



func _on_ledge_check_right_body_exited(body):
	if $LedgeCheckRight.has_overlapping_bodies():
		return
	match current_state:
		States.ROAM:
			self.velocity.x = -LEDGE_VELOCITY
			movement_x_axis *= -1
		States.CHASE:
			print("RIGHT EXIT")
			self.velocity.y = -200
			self.velocity.x = -LEDGE_VELOCITY
			#movement_x_axis *= -1
			charging = false

func _on_chase_area_body_exited(body):
	if body.is_in_group("player"):
		enter_state(States.ROAM)


func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		var player = body
		player.apply_knockback(Vector2(player_x_axis, 0), KNOCKBACK_PLAYER_FORCE)
		player.apply_damage(damage)
		charging = false


func _on_charge_duration_timeout():
#velocity.x = 1000 * facing_x_axis
	charging = false
	#pass 

