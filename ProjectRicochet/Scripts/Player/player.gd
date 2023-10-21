extends CharacterBody2D

class_name Player

const SPEED = 400.0
const ACCELERATION_FACTOR = 4.0
const AIM_FACTOR = 4.0
const MOUSE_POS_SCALE = 0.1
const KNOCKBACK = 400.0
const KNOCKBACK_DELTA = 500.0

const INITIAL_JUMP_VELOCITY = -350.0
const SECOND_JUMP_ADD = -300.0
const SECOND_JUMP_START = -500.0
const JUMP_ADD = -1800.0
const JUMP_DELTA = 15.0
const MAX_JUMP_TIME = 0.25
const MAX_JUMP_VELOCITY = -600.0
const MAX_CAMERA_OFFSET = 400
const NORMAL_FRICTION = 2000.0
const KNOCKBACK_FRICTION = 500.0
const SPRITE_X_SCALE = 1.3
const SPRITE_Y_SCALE = 1.5


const MIN_GUN_CHARGE = 0.1
const MAX_GUN_CHARGE = 0.2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var rng = RandomNumberGenerator.new()
enum States {STANDARD, CROUCHING, DESTROYED}
var current_state = States.STANDARD
var previous_state = States.STANDARD
var direction = 0.0
var health = 1000.0
var friction_factor = NORMAL_FRICTION
var second_jump = false

var jump_charge = 0
var gun_charge = 0

var jump_timer = 0.0

var target_zoom = Vector2(1.0,1.0)
var zoom_delta = 1

var jump_check = 1
@onready var position_is_position = Vector2(0,0)
@onready var player_gun = $Gun
@onready var aimcast = $Gun/AimCast
@onready var player_sprite = $PlayerSprite
@onready var hit_timer = $HitTimer
@onready var knockback_timer = $KnockbackTimer
@onready var shoot_timer = $Gun/ShootTimer
@onready var health_bar = $CanvasLayer/Control/VBoxContainer/HealthLabel
@onready var gun_bar = $CanvasLayer/Control/VBoxContainer/GunChargeLabel
@onready var jump_bar = $CanvasLayer/Control/VBoxContainer/JumpChargeLabel
@onready var hurtbox_area = $HurtboxArea
@onready var stand_hurtbox = $HurtboxArea/StandHurtbox
@onready var crouch_hurtbox = $HurtboxArea/CrouchHurtbox
@onready var laser_sprite = $Gun/Laser
@onready var camera = $Camera
@onready var gun_sound_player = $Sounds/GunSoundPlayer
@onready var hit_sound_player = $Sounds/HitSoundPlayer

@onready var root_node = null

@onready var AdvancedBullet = preload("res://Scenes/Bullets/advanced_ricochet_bullet.tscn")


#@onready var gun_sounds = [GunSound1, GunSound2, GunSound3, GunSound4]


func _ready():
	root_node = get_tree().get_root().get_child(0)


func _physics_process(delta):
	direction = Input.get_axis("ui_left", "ui_right")
	match current_state:
		States.STANDARD:
			standard_state(delta)
		States.CROUCHING:
			crouch_state(delta)
		States.DESTROYED:
			pass
		_:
			var what_the_fuck = true
	general_step(delta)


func general_step(delta):
	camera.zoom = lerp(camera.zoom, target_zoom, delta*zoom_delta)
	gun_bar.set_modulate(Color(0.5,0.5,0.5))
	if Input.is_action_pressed("Shoot"):
		if gun_charge < MAX_GUN_CHARGE:
			gun_charge += delta
		else:
			gun_bar.set_modulate(Color(0.5,0.5,1))
	if Input.is_action_just_released("Shoot"):
		if gun_charge >= MIN_GUN_CHARGE:
			shoot()
		gun_charge = 0
	
	var mouse_local_pos = (get_global_mouse_position() - global_position)
	var mouse_dir = mouse_local_pos.normalized()
	if global_position.distance_to(get_global_mouse_position()) < MAX_CAMERA_OFFSET:
		camera.offset = lerp(camera.offset, -mouse_local_pos*MOUSE_POS_SCALE, delta*AIM_FACTOR)
	else:
		camera.offset = lerp(camera.offset, -mouse_dir*MOUSE_POS_SCALE*MAX_CAMERA_OFFSET, delta*AIM_FACTOR)
	health_bar.text = "HP: "+str(health)
	gun_bar.text = "GUN: "+str(gun_charge)
	jump_bar.text = "JUMP: "+str(jump_timer)
	
	if direction:
		player_sprite.scale.x = SPRITE_X_SCALE * direction
	
	check_jump(delta)
	if is_on_floor(): 
		second_jump = false
		jump_check = 1
	else:
		# Add the gravity.
		velocity.y += gravity * delta
		if sign(velocity.y)*jump_check == 1:
			player_sprite.animation = "fall"
			player_sprite.play()
			jump_check = -1
	move_and_slide()


func standard_state(delta):
	stand_hurtbox.disabled = false
	crouch_hurtbox.disabled = true
	if direction:
		if Input.is_action_pressed("Sprint"):
			velocity.x = lerp(velocity.x, direction * SPEED * 1.5, delta*ACCELERATION_FACTOR)
		else:
			velocity.x = lerp(velocity.x, direction * SPEED, delta*ACCELERATION_FACTOR)
	else:
		velocity.x = move_toward(velocity.x, 0, delta*friction_factor)
	if is_on_floor():
		if not player_sprite.is_playing():
			player_sprite.play()
		if direction:
			if Input.is_action_pressed("Sprint"):
				player_sprite.animation = "run"
			else:
				player_sprite.animation = "walk"
		else:
			player_sprite.animation = "idle"


func  crouch_state(delta):
	stand_hurtbox.disabled = true
	crouch_hurtbox.disabled = false
	velocity.x = move_toward(velocity.x, 0, delta*friction_factor)
	player_sprite.animation = "crouch"
	


func _input(event):
	if event.is_action_pressed("Shoot"):
		#shoot()
		pass
	if event.is_action_pressed("Crouch"):
		if is_on_floor() and current_state != States.CROUCHING:
			enter_state(States.CROUCHING)
	if event.is_action_released("Crouch"):
		enter_state(States.STANDARD)
	if event.is_action("Shoot"):
		pass


func enter_state(state):
	exit_state(current_state)
	match state:
		States.CROUCHING:
			player_sprite.play()
	current_state = state


func exit_state(state):
	match state:
		States.CROUCHING:
			player_sprite.play()
	previous_state = state

func shoot():
	if not player_gun.is_tip_colliding() and shoot_timer.is_stopped():
		var direction = (get_global_mouse_position() - global_position).normalized()
		var new_bullet = AdvancedBullet.instantiate()
		new_bullet.prepare(direction)
		new_bullet.global_position = laser_sprite.global_position
		get_tree().get_root().add_child(new_bullet)
		gun_sound_player.play()
		shoot_timer.start()

func check_jump(delta):
	
	if Input.is_action_just_pressed("ui_accept"):
		jump_timer = 0.0
		if current_state != States.STANDARD:
			enter_state(States.STANDARD)
		if is_on_floor():
			velocity.y = INITIAL_JUMP_VELOCITY
			player_sprite.animation = "jump"
			player_sprite.play()
			jump_check = 1
		elif not second_jump:
			velocity.y = SECOND_JUMP_START
			second_jump = true
			jump_check = 1
	if Input.is_action_pressed("ui_accept") and not is_on_floor():
		jump_timer += delta
		if jump_timer < MAX_JUMP_TIME and not second_jump:
			velocity.y = lerp(velocity.y, MAX_JUMP_VELOCITY, delta*JUMP_DELTA)
	if Input.is_action_just_released("ui_accept") and not is_on_floor():
			jump_timer = 1
		
	#elif Input.is_action_just_released("ui_accept"):
	#	velocity.y = JUMP_VELOCITY
	#	jump_charge = 0
		
	#else:
	#	jump_charge = 0



func apply_damage(damage):
	if hit_timer.is_stopped():
		hurtbox_area.set_collision_layer_value(1, false)
		hurtbox_area.set_collision_mask_value(1, false)
		health -= damage
		hit_sound_player.play()
		hit_timer.start()
		player_sprite.set_modulate(Color(1, 1, 1, 0.5))
		if health <= 0:
			current_state = States.DESTROYED
			queue_free()


func apply_knockback(direction, force=KNOCKBACK):
	knockback_timer.start()
	friction_factor = KNOCKBACK_FRICTION
	velocity = Vector2(force*sign(direction.x), -force)


func hitpoint():
	match current_state:
		States.STANDARD:
			return global_position
		States.CROUCHING:
			return global_position + Vector2(0, 50)
		States.DESTROYED:
			return global_position
		_:
			return global_position 

func change_camera_zoom(zoom_scale, delta_factor=1):
	target_zoom = Vector2(zoom_scale, zoom_scale)
	zoom_delta = delta_factor

func _on_hurtbox_area_body_entered(body):
	pass


func _on_hit_timer_timeout():
	player_sprite.set_modulate(Color(1, 1, 1, 1))
	hurtbox_area.set_collision_layer_value(1, true)
	hurtbox_area.set_collision_mask_value(1, true)


func _on_knockback_timer_timeout():
	friction_factor = NORMAL_FRICTION

