extends CharacterBody2D

@export var player : Player
@export var jump_spots : Node

const SPEED = 300.0
const JUMP_SPEED = 500.0
const JUMP_VELOCITY = -400.0
const SHOTGUN_DISTANCE = 200.0
@onready var path_follow = get_parent()
@onready var navagent : NavigationAgent2D = $NavigationAgent2D
@onready var surround_check : Area2D = $SurroundCheck
@onready var shoot_timer : Timer = $ShootTimer
@onready var Bullet = preload("res://Scenes/Bullets/enemy_bullet.tscn")
var health = 1000
var rng = RandomNumberGenerator.new()
var spawner : Spawner
var boss_scene
var x_axis = 1
var facing_x_axis = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var delta
var is_jumping = false
var shotgun_flag = false

var prev_spot = null
var destroyed = false
var activated = true
func _ready():
	#path_follow.rotates = false
	pass
	
func _physics_process(delta):
	if not activated:
		return
	self.delta = delta
	self.modulate = lerp(self.modulate, Color(1,1,1,1), delta)
	if velocity.x > 0:
		x_axis = 1
	elif velocity.x < 0:
		x_axis = -1
	if weakref(player):
		facing_x_axis = sign(global_position.direction_to(player.global_position).x)
	
		if global_position.distance_to(player.global_position) < SHOTGUN_DISTANCE:
			shotgun_flag = true
			shoot_timer.wait_time = 2
		else:
			shotgun_flag = false
			shoot_timer.wait_time = 3
	
	if abs(velocity.x) < 5:
		$Sprite.animation = "idle"
	else:
		$Sprite.animation = "run"
	
	self.scale.x = x_axis
	$Sprite.scale.x = facing_x_axis * x_axis

	if not is_on_floor():
		if velocity.y < 0:
			$Sprite.animation = "jump"
		else:
			$Sprite.animation = "fall"
		# Add the gravity.
		if is_jumping:
			velocity.y -= gravity * delta
		velocity.y += gravity * delta
	#if global_position.distance_to(player.global_position) < 100:
	# Add the gravity.
	#	path_follow.progress = (path_follow.progress + SPEED * delta)
	#move_and_slide()
	if navagent.is_navigation_finished():
		if is_on_floor():
			disable_jump()
		
		velocity.x = lerp(velocity.x, 0.0, delta)
		move_and_slide()
		return
	else:
		var next = navagent.get_next_path_position()
		#var axis = to_local(navagent.get_next_path_position().normalized())
		var axis = global_position.direction_to(next)
		#var intented_velocity = (next - global_position).normalized() * SPEED

		var intended_velocity
		if is_jumping:
			intended_velocity = axis * JUMP_SPEED
			#if axis.y > 0:
			#	intended_velocity.y += gravity * 0.2
		else:
			intended_velocity = axis * SPEED
		navagent.set_velocity(intended_velocity)
		#move_and_slide()



func _input(event):
	if event.is_action_pressed("TestAction"):
		navagent.target_position = get_global_mouse_position()
		#if global_position.direction_to(navagent.get_next_path_position()).y < 0:
		#	enable_jump()


func move():
	var next_spot
	var dist = INF
	for spot in jump_spots.get_children():
		if spot == prev_spot:
			continue
		var to_spot_vect = spot.global_position - global_position
		var to_spot = global_position.distance_to(spot.global_position)
		if to_spot < dist:
			next_spot = spot
			dist = to_spot
	navagent.target_position = next_spot.global_position
	prev_spot = next_spot
	if global_position.direction_to(navagent.get_next_path_position()).y < 0:
		enable_jump()

func apply_damage(damage):
	set_modulate(Color(1,0.2,0.2,0.8))
	if boss_scene != null:
		if damage < health:
			boss_scene.boss_health -= damage
		else:
			boss_scene.boss_health -= health
	health -= damage
func apply_knockback(force, direction):
	pass

func shoot():
	if shotgun_flag or global_position.distance_to(player.global_position) < SHOTGUN_DISTANCE:
		var new_bullet = Bullet.instantiate()
		var new_bullet2 = Bullet.instantiate()
		var new_bullet3 = Bullet.instantiate()
		new_bullet.global_position = global_position
		new_bullet2.global_position = global_position
		new_bullet3.global_position = global_position
		var direction = global_position.direction_to(player.hitpoint())
		var direction2 = direction.rotated(PI/8)
		var direction3 = direction.rotated(-PI/8)
		new_bullet.scale = Vector2(0.2,0.2)
		new_bullet2.scale = Vector2(0.2,0.2)
		new_bullet3.scale = Vector2(0.2,0.2)
		new_bullet.speed = 370
		new_bullet2.speed = 370
		new_bullet3.speed = 370
		new_bullet.prepare(direction)
		get_tree().get_root().add_child(new_bullet)
		new_bullet2.prepare(direction2)
		get_tree().get_root().add_child(new_bullet2)
		new_bullet3.prepare(direction3)
		get_tree().get_root().add_child(new_bullet3)
	else:
		for n in range(3):
			var new_bullet = Bullet.instantiate()
			new_bullet.global_position = global_position
			var direction = global_position.direction_to(player.hitpoint())
			new_bullet.speed = 320
			new_bullet.scale = Vector2(0.3,0.3)
			new_bullet.prepare(direction)
			get_tree().get_root().add_child(new_bullet)
			
			#$ShootSound2D.play()
			await get_tree().create_timer(0.2).timeout

func enable_jump():
	is_jumping = true
	navagent.path_desired_distance = 40
	$FallTimer.start()

func disable_jump():
	is_jumping = false
	navagent.path_desired_distance = 10


func avoid_bullet(incoming_dir : Vector2, bullet_dir: Vector2, incoming_pos: Vector2):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(incoming_pos, incoming_pos+bullet_dir*100)
	query.collision_mask = 9
	var result = space_state.intersect_ray(query)
	var new_pos = Vector2(0,0)
	print(result)
	print(abs(incoming_dir.y))
	if result:
		if abs(incoming_dir.x) > 0.8:
			if is_on_floor():
				velocity.y = -220
			else:
				velocity.y = sign(incoming_dir.y) * -200
		elif abs(incoming_dir.y) > 0.8:
			velocity.y = -50
			velocity.x = sign(incoming_dir.x) * 220

		else:
			if is_on_floor():
				if incoming_dir.y > 0:
					#if incoming_dir.x > 0
					velocity.y = -60
					velocity.x = sign(incoming_dir.x) * 200

				else:
					velocity.y = -50
					velocity.x = sign(incoming_dir.x) * 200

			else:
				#velocity = incoming_dir.orthogonal() * 300
				velocity.y = incoming_dir.y * -300
				velocity.x = incoming_dir.x * 300



func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	if not activated:
		return
	if is_on_floor():
		velocity = safe_velocity
	else:
		if self.delta != null:
			velocity = lerp(velocity, safe_velocity, self.delta*1.65)
	move_and_slide()


func _on_area_2d_body_exited(body):
	
	if not navagent.is_navigation_finished():
		enable_jump()
	else:
		move()
		enable_jump()


func _on_timer_timeout():
	var r = rng.randf_range(0.0, 1.0)
	if r < 0.35:
		var height_offset = 25
		navagent.target_position = Vector2(player.global_position.x, player.global_position.y+height_offset)
	else:
		move()
	#surround_check.get_overlapping_bodies()


func _on_navigation_agent_2d_path_changed():
	print("I HAVE CHANGED")


func _on_surround_check_body_entered(body):
	if body.is_in_group("player_bullets"):
		if body.bounces > 0:
			var incoming_dir = global_position.direction_to(body.global_position)
			#var avoid_dir = incoming_dir.orthogonal()
			#velocity = avoid_dir * 200
			avoid_bullet(incoming_dir, body.direction, body.global_position)
		#if $FallTimer.is_stopped():
		#	move()
		#	$MoveTimer.start()
	#pass # Replace with function body.


func _on_fall_timer_timeout():
	#disable_jump()
	if not is_on_floor():
		move()
	#	navagent.target_position = prev_spot.global_position
	pass # Replace with function body.


func _on_shoot_timer_timeout():
	shoot()


func _on_shotgun_check_body_entered(body):
	if body.is_in_group("player"):
		shoot()
		move()