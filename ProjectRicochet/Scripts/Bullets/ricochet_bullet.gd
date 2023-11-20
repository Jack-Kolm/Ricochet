extends Area2D

var BASE_DAMAGE = 200

var current_damage

@onready var bullet_cast = $BulletCast
@onready var timer = $DestructionTimer
@onready var bullet_sprite = $BulletSprite
@onready var explosion_sprite = $ExplosionSprite
@onready var animation_player = $AnimationPlayer
@onready var sound_player = $RicochetSoundPlayer2D

@onready var speed = 0
@onready var direction = Vector2(0,0)
@onready var points = []

@onready var should_bounce = false
@onready var current_goal = null
@onready var next_point = null
var bounces = 0
var max_bounces = 6
var destroyed = false

var impact1 = preload("res://Sounds/Impact/metal_solid_impact_bullet1.wav")
var impact2 = preload("res://Sounds/Impact/metal_solid_impact_bullet2.wav")
var impact3 = preload("res://Sounds/Impact/metal_solid_impact_bullet3.wav")
var impact4 = preload("res://Sounds/Impact/metal_solid_impact_bullet4.wav")
var rng = RandomNumberGenerator.new()
var impact_sounds = [impact1, impact2, impact3, impact4]
# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("bullets")
	current_damage = BASE_DAMAGE
	explosion_sprite.visible = false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not destroyed:
		self.step(delta)
func step(delta):
	"""
	if should_bounce and points.is_empty() == false:
		speed = speed + speed*0.2
		current_damage = BASE_DAMAGE * bounces
		bullet_sprite.set_modulate(Color(1, 1, 1, 1))
		current_goal = points.pop_front()
		next_point = current_goal[0]
		direction = global_position.direction_to(next_point)
		var index = rng.randi_range(0,3)
		sound_player.stream = impact_sounds[index]
		sound_player.play()
		sound_player.volume_db += 3
		sound_player.pitch_scale += 0.3
		should_bounce = false
	
	if global_position.distance_to(next_point) < 15:
		bounces += 1
		if bullet_sprite.frame < 6:
			bullet_sprite.frame += 1
		
		if bounces >= max_bounces:
			destroy()
		
		if current_goal[1]:
			if bounces > 1:
				var enemy = current_goal[1]
				var wr = weakref(enemy)
				#if wr.get_ref():
					#enemy.death()
			#destroy()
		should_bounce = true
	"""
	if should_bounce:
		speed = speed + speed*0.2
		current_damage = BASE_DAMAGE * bounces
		bullet_sprite.set_modulate(Color(1, 1, 1, 1))
		#current_goal = points.pop_front()
		#next_point = current_goal[0]
		#direction = global_position.direction_to(next_point)
		#direction = global_position.direction_to(next_point)
		var index = rng.randi_range(0,3)
		sound_player.stream = impact_sounds[index]
		sound_player.play()
		sound_player.volume_db += 3
		sound_player.pitch_scale += 0.3
		should_bounce = false
		
	#if bullet_cast.is_colliding():
		
		
	global_position += (direction * speed)*delta*100 #+ Vector2(10,0) 
	rotation = direction.angle() - (PI/2)


func prepare_bullet(new_speed, travel_points, start_spot):
	self.speed = new_speed
	self.points = travel_points
	#self.max_bounces = travel_points.size()
	self.current_goal = self.points.pop_front()
	self.next_point = self.current_goal[0]
	self.direction = start_spot.direction_to(self.next_point)
	self.should_bounce = false
	self.bullet_sprite.set_modulate(Color(1, 1, 1, 0.4))

func destroy():
	destroyed = true
	self.set_collision_layer_value(2, false)
	self.set_collision_mask_value(2, false)
	bullet_sprite.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("default")
	#queue_free()

func _on_destruction_timer_timeout():
	#destroy()
	queue_free()


func _on_body_entered(body):
	if bounces > 0:
		if body.is_in_group("enemies"):
			var bat = body
			bat.take_damage(current_damage)
			bat.apply_force(100*bounces, direction)
			self.destroy()



func _on_explosion_sprite_animation_finished():
	explosion_sprite.visible = false
	queue_free()
	pass # Replace with function body.


func _on_wall_check_body_entered(body):
	var query = PhysicsRayQueryParameters2D.create(global_position, direction*1000)
	query.set_collision_mask(1)
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(query)

	#var collision_point = bullet_cast.get_collision_point()
	#var normal = bullet_cast.get_collision_normal()
	#body.get_collision_normal
	#var new_dir = direction.bounce(normal).normalized()
	#var new_goal = collision_point + new_dir*10000
	if result:
		var collision_point = result["position"]
		var normal = result["normal"]
		#direction = new_dir
		var new_dir = direction.bounce(normal).normalized()
		var new_goal = collision_point + new_dir*10000
		direction = new_dir
		next_point = new_goal
		bounces += 1
		#bounces += 1
		if bullet_sprite.frame < 6:
			bullet_sprite.frame += 1
		if bounces >= max_bounces:
			destroy()
		should_bounce = true
	#else:
	#	next_point = direction * 10000


