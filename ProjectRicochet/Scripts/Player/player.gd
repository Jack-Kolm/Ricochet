extends CharacterBody2D

class_name Player

const SPEED = 150.0
const SPRINT_SPEED = 300.0
const ACCELERATION_FACTOR = 4.0
const AIM_FACTOR = 4.0
const MOUSE_POS_SCALE = 0.1
const KNOCKBACK = 400.0
const KNOCKBACK_DELTA = 500.0

const INITIAL_JUMP_VELOCITY = -200.0
const SECOND_JUMP_ADD = -200.0
const SECOND_JUMP_START = -420.0
const JUMP_ADD = -1500.0
const JUMP_DELTA = 15.0
const MAX_JUMP_TIME = 0.3
const MAX_JUMP_VELOCITY = -400.0
const MAX_CAMERA_OFFSET = 300
const NORMAL_FRICTION = 2000.0
const KNOCKBACK_FRICTION = 500.0
const SPRITE_X_SCALE = 0.7
const SPRITE_Y_SCALE = 0.75

const FADE_DELTA = 2

const GUN_RIGHT_Y = 0.24
const GUN_LEFT_Y = -0.24
const GUN_OFFSET_X = 6

const MIN_GUN_CHARGE = 0.1
const MAX_GUN_CHARGE = 0.2

const OUTLINE_NORMAL = Color(0.7, 0.5, 1.0, 1.0)
const OUTLINE_HURT = Color(0.2, 0.1, 0.4, 1.0)



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var rng = RandomNumberGenerator.new()
enum States {STANDARD, CROUCHING, DEATH}
var current_state = States.STANDARD
var previous_state = States.STANDARD
var direction = 0.0
var health = Global.PLAYER_MAX_HEALTH
var friction_factor = NORMAL_FRICTION
var second_jump = false

var jump_charge = 0
var gun_charge = 0

var jump_timer = 0.0

var target_zoom = Vector2(1.0,1.0)
var zoom_delta = 1

var jump_fall_check = 1
var is_jumping = false
var fall_point = Vector2()

var boss_flag = false

@onready var position_is_position = Vector2(0,0)
@onready var gun = $Gun
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

@onready var inner_ring = $CanvasLayer/Control/Rings/Inner
@onready var inner_inner_ring = $CanvasLayer/Control/Rings/InnerInner
@onready var outer_ring = $CanvasLayer/Control/Rings/Outer
@onready var rings = $CanvasLayer/Control/Rings

@onready var blackscreen1 = $Blackscreen1
@onready var blackscreen2 = $Blackscreen2

@onready var root_node = null

@onready var AdvancedBullet = preload("res://Scenes/Bullets/advanced_ricochet_bullet.tscn")


#@onready var gun_sounds = [GunSound1, GunSound2, GunSound3, GunSound4]


func _ready():
	root_node = get_tree().get_root().get_child(0)
	blackscreen1.modulate.a = 0
	blackscreen2.modulate.a = 0
	if Global.revive_flag:
		heal()
		Global.revive_flag = false
	#health = Global.player_health
	#bbc.texture()

func _physics_process(delta):
	direction = Input.get_axis("ui_left", "ui_right")
	match current_state:
		States.STANDARD:
			standard_state(delta)
		States.CROUCHING:
			crouch_state(delta)
		States.DEATH:
			death_state(delta)


func general_step(delta):
	$CanvasLayer/HealthBar/InnerBar.scale.x = Global.player_health / Global.PLAYER_MAX_HEALTH
	$Gun/MuzzleFlash.energy = lerp($Gun/MuzzleFlash.energy, 0.0, delta*JUMP_DELTA)
	$HurtSprite.material.set_shader_parameter("tint", lerp($HurtSprite.material.get_shader_parameter("tint"), Color.BLACK, delta))
	camera.zoom = lerp(camera.zoom, target_zoom, delta*zoom_delta)
	if Input.is_action_just_released("Shoot"):
		var inner_ring_offset = 0.05
		if outer_ring.scale.x <= inner_ring.scale.x + inner_ring_offset and outer_ring.scale.x > inner_inner_ring.scale.x:
			shoot()
		
	if Input.is_action_pressed("Shoot"):
		var aim_speed_delta = 1.8
		var outer_min_scale = Vector2(0.1,0.1)
		outer_ring.visible = true
		outer_ring.scale = lerp(outer_ring.scale, outer_min_scale, delta*aim_speed_delta)
		outer_ring.modulate = lerp(outer_ring.modulate, Color(255,255,255, 1), delta)

	else:
		outer_ring.modulate = Color(255,255,255,0)
		outer_ring.visible = false
		outer_ring.scale = Vector2(1,1)
	var mouse_local_pos = (get_global_mouse_position() - global_position)
	var mouse_dir = mouse_local_pos.normalized()
	if global_position.distance_to(get_global_mouse_position()) < MAX_CAMERA_OFFSET:
		camera.offset = lerp(camera.offset, mouse_local_pos*MOUSE_POS_SCALE, delta*AIM_FACTOR)
	else:
		camera.offset = lerp(camera.offset, mouse_dir*MOUSE_POS_SCALE*MAX_CAMERA_OFFSET, delta*AIM_FACTOR)
	if mouse_dir.x > 0:
		gun.scale.y = GUN_RIGHT_Y
		gun.angle_offset = PI/2
		player_sprite.scale.x = SPRITE_X_SCALE
	else:
		gun.scale.y = GUN_LEFT_Y
		gun.angle_offset = 3*(PI/2)
		player_sprite.scale.x = -SPRITE_X_SCALE
	health_bar.text = "Player health: "+str(Global.player_health)
	check_jump(delta)
	if is_on_floor(): 
		if is_jumping:
			var fall_distance = fall_point.distance_to(global_position)
			print(fall_distance)
		is_jumping = false
		second_jump = false
		jump_fall_check = 1
	else:
		# Add the gravity.
		velocity.y += gravity * delta
		if sign(velocity.y)*jump_fall_check == 1:
			fall_point = global_position
			player_sprite.animation = "fall"
			player_sprite.play()
			jump_fall_check = -1
	move_and_slide()


func standard_state(delta):
	stand_hurtbox.disabled = false
	crouch_hurtbox.disabled = true
	if direction:
		if Input.is_action_pressed("Sprint"):
			velocity.x = lerp(velocity.x, direction * SPEED, delta*ACCELERATION_FACTOR)
		else:
			velocity.x = lerp(velocity.x, direction * SPRINT_SPEED, delta*ACCELERATION_FACTOR)
	else:
		velocity.x = move_toward(velocity.x, 0, delta*friction_factor)
	if is_on_floor():
		if not player_sprite.is_playing():
			player_sprite.play()
		if direction:
			var aim_dir = sign(global_position.direction_to(get_global_mouse_position()).x)
			if aim_dir*direction != 1:
				player_sprite.animation = "backwalk"
				if $Sounds/WalkSound.playing == false:
					$Sounds/WalkSound.play()
					$Sounds/RunSound.stop()
			elif Input.is_action_pressed("Sprint"):
				player_sprite.animation = "walk"
				if $Sounds/WalkSound.playing == false:
					$Sounds/WalkSound.play()
					$Sounds/RunSound.stop()
			else:
				player_sprite.animation = "run"
				if $Sounds/RunSound.playing == false:
					$Sounds/RunSound.play()
					$Sounds/WalkSound.stop()
		else:
			$Sounds/WalkSound.stop()
			$Sounds/RunSound.stop()
			player_sprite.animation = "idle"
	general_step(delta)


func crouch_state(delta):
	stand_hurtbox.disabled = true
	crouch_hurtbox.disabled = false
	velocity.x = move_toward(velocity.x, 0, delta*friction_factor)
	player_sprite.animation = "crouch"
	general_step(delta)


func death_state(delta):
	camera.zoom = lerp(camera.zoom, target_zoom, delta*zoom_delta)
	hurtbox_area.set_collision_layer_value(1, false)
	hurtbox_area.set_collision_mask_value(1, false)
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	#self.set_modulate(Color(1, 1, 1, 0.3))
	self.material.set_shader_parameter("color",OUTLINE_NORMAL)
	gun.visible = false
	blackscreen1.z_index = 3
	player_sprite.z_index = 4
	blackscreen2.z_index = 5
	blackscreen1.modulate.a = lerp(blackscreen1.modulate.a, 1.0, delta*FADE_DELTA)
	rings.modulate.a = lerp(rings.modulate.a, 0.0, delta)
	camera.offset = lerp(camera.offset, Vector2(0,0), delta)
	velocity = Vector2(0,0)
	
	if blackscreen1.modulate.a >= 0.99:
		blackscreen2.modulate.a = lerp(blackscreen2.modulate.a, 1.0, delta*FADE_DELTA)
		if blackscreen2.modulate.a >= 0.99:
			print(get_parent().name)
			if get_parent().name == "BossLevel":
				get_parent().cleanup()
			SceneSwitcher.switch_scene(SceneSwitcher.Scenes.RESTART)


func _input(event):
	if event.is_action_pressed("Shoot"):
		#shoot()
		pass
	#if event.is_action_pressed("Crouch"):
	#	if is_on_floor() and current_state != States.CROUCHING:
	#		enter_state(States.CROUCHING)
	if event.is_action_released("Crouch"):
		enter_state(States.STANDARD)
	if event.is_action("Shoot"):
		pass


func enter_state(state):
	exit_state(current_state)
	current_state = state
	match state:
		States.CROUCHING:
			player_sprite.play()
		States.DEATH:
			blackscreen1.z_index = 7
			player_sprite.z_index = 8
			blackscreen2.z_index = 9
			player_sprite.play("death")
			blackscreen1.visible = true
			blackscreen2.visible = true
			change_camera_zoom(5, 1)
			#AudioServer.set_bus_mute(1, true)
			#AudioServer.set_bus_mute(2, true)
			$Sounds/DeathSound.play()
			$CanvasLayer/HealthBar.visible = false


func exit_state(state):
	match state:
		States.CROUCHING:
			player_sprite.play()
	previous_state = state


func shoot():
	if not gun.is_tip_colliding() and shoot_timer.is_stopped():
		var direction = (get_global_mouse_position() - $Gun/GunTipBox.global_position).normalized()
		var new_bullet = AdvancedBullet.instantiate()
		
		gun.recoil(direction)
		
		var shake_amount = 3
		var r1 = rng.randf_range(-1.0, 1.0)
		var r2 = rng.randf_range(-1.0, 1.0)
		camera.set_offset(camera.offset - direction)
		
		new_bullet.prepare(direction)
		new_bullet.global_position = laser_sprite.global_position
		get_tree().get_root().add_child(new_bullet)
		gun_sound_player.play()
		shoot_timer.start()
		$Gun/MuzzleFlash.energy = 10


func check_jump(delta):
	if Input.is_action_just_pressed("Jump"):
		jump_timer = 0.0
		if current_state != States.STANDARD:
			enter_state(States.STANDARD)
		if is_on_floor():
			velocity.y = INITIAL_JUMP_VELOCITY
			player_sprite.animation = "jump"
			player_sprite.play()
			$Sounds/JumpSound.play()
			jump_fall_check = 1
			is_jumping = true
		elif not second_jump:
			$Sounds/JumpSound.play()
			velocity.y = SECOND_JUMP_START
			second_jump = true
			jump_fall_check = 1
	if Input.is_action_pressed("Jump") and not is_on_floor():
		jump_timer += delta
		if jump_timer < MAX_JUMP_TIME and not second_jump:
			velocity.y = lerp(velocity.y, MAX_JUMP_VELOCITY, delta*JUMP_DELTA)
	if Input.is_action_just_released("Jump") and not is_on_floor():
			jump_timer = 1


func apply_damage(damage):
	if hit_timer.is_stopped():
		hurtbox_area.set_collision_layer_value(1, false)
		hurtbox_area.set_collision_mask_value(1, false)
		Global.player_health -= damage
		hit_sound_player.play()
		hit_timer.start()
		#self.set_modulate(Color(1, 1, 1, 0.3))
		self.material.set_shader_parameter("color",OUTLINE_HURT)
		if Global.player_health <= 0:
			destroy()  


func destroy():
	Global.revive_flag = true
	enter_state(States.DEATH)


func heal():
	Global.player_health = Global.PLAYER_MAX_HEALTH


func apply_knockback(direction, force=KNOCKBACK):
	if hit_timer.is_stopped():
		knockback_timer.start()
		friction_factor = KNOCKBACK_FRICTION
		velocity = Vector2(force*sign(direction.x), -force)


func hitpoint():
	match current_state:
		States.STANDARD:
			return global_position
		States.CROUCHING:
			return global_position + Vector2(0, 50)
		States.DEATH:
			return global_position
		_:
			return global_position 

func change_camera_zoom(zoom_scale, delta_factor=1):
	var current_zoom = target_zoom.x
	var current_delta = zoom_delta
	target_zoom = Vector2(zoom_scale, zoom_scale)
	zoom_delta = delta_factor
	return [current_zoom, zoom_delta]

func _on_hurtbox_area_body_entered(body):
	pass


func _on_hit_timer_timeout():
	#self.set_modulate(Color(1, 1, 1, 1))
	self.material.set_shader_parameter("color",OUTLINE_NORMAL)
	hurtbox_area.set_collision_layer_value(1, true)
	hurtbox_area.set_collision_mask_value(1, true)


func _on_knockback_timer_timeout():
	friction_factor = NORMAL_FRICTION



