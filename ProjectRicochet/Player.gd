extends CharacterBody2D

class_name Player

const SPEED = 400.0
const JUMP_VELOCITY = -600.0
const ACCELERATION_FACTOR = 4.0
const AIM_FACTOR = 4.0
const MOUSE_POS_SCALE = 0.2
const KNOCKBACK = 400.0
const KNOCKBACK_DELTA = 500.0

const NORMAL_FRICTION = 2000.0
const KNOCKBACK_FRICTION = 500.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var rng = RandomNumberGenerator.new()
enum States {STANDARD, CROUCHING, DESTROYED}
var current_state = States.STANDARD
var direction = 0.0
var health = 1000.0
var friction_factor = NORMAL_FRICTION

@onready var position_is_position = Vector2(0,0)
@onready var player_gun = $Gun
@onready var aimcast = $Gun/AimCast
@onready var player_sprite = $PlayerSprite
@onready var hit_timer = $HitTimer
@onready var knockback_timer = $KnockbackTimer
@onready var shoot_timer = $Gun/ShootTimer
@onready var health_bar = $CanvasLayer/Control/MarginContainer/Label
@onready var hurtbox_area = $HurtboxArea
@onready var stand_hurtbox = $HurtboxArea/StandHurtbox
@onready var crouch_hurtbox = $HurtboxArea/CrouchHurtbox
@onready var laser_sprite = $Gun/Laser
@onready var camera = $Camera2D

@onready var gun_sound_player = $Sounds/GunSoundPlayer
@onready var hit_sound_player = $Sounds/HitSoundPlayer

@onready var root_node = null
#@onready var Bullet = preload("res://bullet.tscn")
@onready var Bullet = preload("res://ricochet_bullet.tscn")
@onready var AdvancedBullet = preload("res://advanced_ricochet_bullet.tscn")
@onready var TestItem = preload("res://test_item.tscn")

#@onready var gun_sounds = [GunSound1, GunSound2, GunSound3, GunSound4]


func _ready():
	print(get_tree().get_root())
	root_node = get_tree().get_root().get_child(0)
	#root_node.set_player(self)


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
			print("how sway")
	general_step(delta)


func general_step(delta):
	var mouse_dir = (get_global_mouse_position() - global_position)
	camera.offset = lerp(camera.offset, mouse_dir*MOUSE_POS_SCALE, delta*AIM_FACTOR)
	health_bar.text = "HP: "+str(health)
	if direction:
		player_sprite.scale.x = 2 * direction
	if not is_on_floor():
		# Add the gravity.
		velocity.y += gravity * delta
		player_sprite.animation = "jump"
	move_and_slide()


func standard_state(delta):
	stand_hurtbox.disabled = false
	crouch_hurtbox.disabled = true
	if direction:
		velocity.x = lerp(velocity.x, direction * SPEED, delta*ACCELERATION_FACTOR)
	else:
		velocity.x = move_toward(velocity.x, 0, delta*friction_factor)
	if is_on_floor():
		if direction:
			player_sprite.animation = "walk"
		else:
			player_sprite.animation = "idle"
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY


func  crouch_state(delta):
	stand_hurtbox.disabled = true
	crouch_hurtbox.disabled = false
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, delta*friction_factor)
		player_sprite.animation = "crouch"
		#player_sprite.frame = 0
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY
			exit_crouch_state()


func exit_crouch_state():
	current_state = States.STANDARD
	player_sprite.play()


func _input(event):
	if event.is_action_pressed("Shoot"):
		shoot()
	if event.is_action_pressed("Crouch"):
		player_sprite.play()
		current_state = States.CROUCHING
	if event.is_action_released("Crouch"):
		exit_crouch_state()


func shoot():
	if not player_gun.is_tip_colliding() and shoot_timer.is_stopped():
		var direction = (get_global_mouse_position() - global_position).normalized()
		var new_bullet = AdvancedBullet.instantiate()
		new_bullet.prepare(direction)
		new_bullet.global_position = laser_sprite.global_position
		get_tree().get_root().add_child(new_bullet)
		gun_sound_player.play()
		shoot_timer.start()



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


func _on_hurtbox_area_body_entered(body):
	pass


func _on_hit_timer_timeout():
	player_sprite.set_modulate(Color(1, 1, 1, 1))
	hurtbox_area.set_collision_layer_value(1, true)
	hurtbox_area.set_collision_mask_value(1, true)


func _on_knockback_timer_timeout():
	friction_factor = NORMAL_FRICTION

