extends CharacterBody2D

class_name ShieldEnemyBase

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


const STOP_CHASE_X = 1200
const STOP_CHASE_Y = 600

const KNOCKBACK_X = 300
const KNOCKBACK_Y = 300
const KNOCKBACK_PLAYER_FORCE = 500

const SPRITE_SCALE = 1

@export var stationary = false
@export var movement_x_axis = 1
@export var size_scale = 2.0
@export var detect_player_x = 800
@export var toward_target_distance = 300
@export var away_target_distance = 400
 
var detect_player_y = 400

enum States {ROAM, CHASE, HURT}
var current_state = States.ROAM
var previous_state = null

var damage
var health

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var destroyed = false
var should_stop = false
var charging = false
var player = null

var facing_x_axis = movement_x_axis
var player_x_axis = null

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
	setup()


func setup():
	var root_node = get_tree().get_root().get_child(0)
	player = root_node.player
	if weakref(player).get_ref():
		navigation_agent.set_target_position(player.global_position)
	self.scale.x = size_scale
	self.scale.y = size_scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
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


# Called no matter state
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
		shield.scale.x = facing_x_axis
		wall_check.scale.x = facing_x_axis
		player_check.scale.x = facing_x_axis
		sprite.scale.x = facing_x_axis
		hitbox.scale.x = facing_x_axis


func roam_step(delta):
	facing_x_axis = movement_x_axis
	general_step(delta)
	if is_on_floor():
		if should_stop or stationary:
			velocity.x = lerp(velocity.x, 0.0, delta*STOP_FACTOR)
		else:
			velocity.x =  move_toward(velocity.x, movement_x_axis * SPEED, delta * MOVE_FACTOR)


func hurt_step(delta):
	general_step(delta)
	velocity.x = move_toward(velocity.x, 0.0, delta*KNOCKBACK_DELTA)


func chase_step(delta):
	pass


func enter_state(state):
	exit_state(current_state)
	match state:
		States.CHASE:
			facing_x_axis = player_x_axis
			stationary = false
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


func turn_around():
	if turn_around_timer.is_stopped() and turn_to_player_timer.is_stopped():
		movement_x_axis *= -1
		turn_around_timer.start()


func apply_damage(damage):
	sprite.set_modulate(Color(40, 0.5, 0.5))
	health -= damage
	if health <= 0:
		destroy()


func apply_knockback(force, direction):
	enter_state(States.HURT)
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


func _on_hurtbox_body_entered(body):
	if body.is_in_group("ricochet_bullets"):
		enter_state(States.CHASE)
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
			turn_around()
		States.CHASE:
			velocity.x =  LEDGE_VELOCITY * -movement_x_axis
	if current_state != States.HURT:
		pass



func _on_ledge_check_left_body_exited(body):
	match current_state:
		States.ROAM:
			velocity.x = LEDGE_VELOCITY
			turn_around()
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
		enter_state(States.ROAM)


func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		var player = body
		player.apply_damage(damage)
		player.apply_knockback(Vector2(player_x_axis, 0), KNOCKBACK_PLAYER_FORCE)


func _on_charge_duration_timeout():
#velocity.x = 1000 * facing_x_axis
	charging = false
	#pass 

