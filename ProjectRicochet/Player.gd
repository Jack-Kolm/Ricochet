extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var rng = RandomNumberGenerator.new()
enum States {STANDARD, CROUCHING, DESTROYED}
var current_state = States.STANDARD
var direction = 0
var health = 100

var friction_factor = 2000

@onready var position_is_position = Vector2(0,0)

@onready var player_gun = $Gun
@onready var aimcast = $Gun/AimCast
@onready var player_sprite = $PlayerSprite
@onready var hit_timer = $HitTimer
@onready var knockback_timer = $KnockbackTimer
@onready var shoot_timer = $Gun/ShootTimer
@onready var health_bar = $CanvasLayer/Control/MarginContainer/Label
@onready var hurtbox = $HurtboxArea
@onready var crouch_hurtbox = $CrouchHurtboxArea

@onready var gun_sound_player = $Sounds/GunSoundPlayer
@onready var hit_sound_player = $Sounds/HitSoundPlayer

@onready var root_node = null

#@onready var Bullet = preload("res://bullet.tscn")
@onready var Bullet = preload("res://ricochet_bullet.tscn")
@onready var AdvancedBullet = preload("res://advanced_ricochet_bullet.tscn")
@onready var TestItem = preload("res://test_item.tscn")

#@onready var gun_sounds = [GunSound1, GunSound2, GunSound3, GunSound4]


func _ready():
	root_node = get_tree().get_root().get_child(0)
	root_node.set_player(self)


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
	default_step(delta)


func default_step(delta):
	health_bar.text = "HP: "+str(health)
	if direction:
		player_sprite.scale.x = 2 * direction
	if not is_on_floor():
		# Add the gravity.
		velocity.y += gravity * delta
		player_sprite.animation = "jump"
	move_and_slide()


func standard_state(delta):
	if direction:
		velocity.x = lerp(velocity.x, direction * SPEED, delta*5)
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
		var direction = (get_global_mouse_position() - self.global_position).normalized()
		var new_bullet = AdvancedBullet.instantiate()
		new_bullet.prepare(direction*800)
		new_bullet.global_position = self.global_position + direction * 40
		get_tree().get_root().add_child(new_bullet)
		gun_sound_player.play()
		shoot_timer.start()
		"""
		var i = rng.randf_range(0, 3)
		gun_sound_player.stream = self.gun_sounds[i]
		"""


func make_bounces(query, direction, space_state, list=[], i=0, max_bounces=6):
	"""
	Calculates bounces for hitscan ricocheting bullet recursively
	"""
	var result = space_state.intersect_ray(query)
	if result:
		# Get bounce dir
		var collision_point = result["position"]
		var normal = result["normal"]
		var new_dir = direction.bounce(normal).normalized()
		
		# Visualize the bounce
		var test_item = TestItem.instantiate()
		test_item.global_position = (collision_point)
		get_tree().get_root().add_child(test_item)
		# Append collision spot to list
		#print(result["collider"].name)
		if result["collider"].is_in_group("enemies"):
			var new_goal = collision_point + direction*10000
			var new_query = PhysicsRayQueryParameters2D.create(collision_point, new_goal)
			#list.append([collision_point, result["collider"]])
			return make_bounces(new_query, direction, space_state, list, i, max_bounces+1)
		else:
			list.append([collision_point, null])
		
		# Make bounce query
		var new_goal = collision_point + new_dir*10000
		var new_query = PhysicsRayQueryParameters2D.create(collision_point, new_goal)
		new_query.exclude = [result["rid"]]
		new_query.set_collision_mask(1)
		i += 1
		
		if i >= max_bounces:
			return list
		return make_bounces(new_query, new_dir, space_state, list, i, max_bounces)
	else:
		# Append non-colliding spot to list
		var point = global_position + direction * 10000
		list.append([point, null])
		return list


func apply_knockback(force, direction):
	knockback_timer.start()
	velocity = Vector2(0,0)
	self.friction_factor = 500
	if direction.x > 0:
		velocity += Vector2(400, -300)
		
	else:
		velocity += Vector2(-400, -300)


func take_damage(damage, dir=null):
	if hit_timer.is_stopped():
		self.health -= damage
		hit_sound_player.play()
		hit_timer.start()
		self.player_sprite.set_modulate(Color(1, 1, 1, 0.5))
		if dir:
			apply_knockback(1000, dir)
		if health <= 0:
			current_state = States.DESTROYED
			queue_free()


func _on_hurtbox_area_body_entered(body):
	pass


func _on_hit_timer_timeout():
	self.player_sprite.set_modulate(Color(1, 1, 1, 1))


func _on_knockback_timer_timeout():
	self.friction_factor = 2000

