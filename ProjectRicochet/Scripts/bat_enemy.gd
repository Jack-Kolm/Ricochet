extends CharacterBody2D

const BASE_SPEED = 200
const CHARGE_SPEED = 200
const CHARGE_DISTANCE = 300
const BODY_DAMAGE = 10
var health = 800

@onready var collision_box = $CollisionBoxShape
@onready var sprite = $Sprite
@onready var explosion_sprite = $ExplosionSprite
@onready var hit_sound_player = $HitSoundPlayer2D
@onready var hitbox_shape = $Hitbox/HitboxShape

var hit_sound = preload("res://Sounds/hitHurtEnemy.wav")
var death_sound = preload("res://Sounds/explosion.wav")

var group = []
var player = null
var root_node = null
var goal = null
var is_bat=true
var destroyed = false
var direction = Vector2(0,0)
var angle = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("enemies")
	explosion_sprite.visible = false
	root_node = get_tree().get_root().get_child(0)
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not destroyed:
		step(delta)


func step(delta):
	sprite.set_modulate(lerp(sprite.get_modulate(), Color(1,1,1), delta)) 
		
	if weakref(player).get_ref():
		goal = player.hitpoint()
		var distance = global_position.distance_to(goal)
		direction = global_position.direction_to(player.global_position)
		#global_position += (direction * 10)
		if distance < CHARGE_DISTANCE:
			velocity = lerp(velocity, direction * CHARGE_SPEED, delta)
		else:
			velocity.x = move_toward(velocity.x, direction.x * BASE_SPEED, delta)
			velocity.y = move_toward(velocity.y, direction.y * BASE_SPEED, delta)
		figure_eight(100, delta)
	#translate(velocity)
	boids(0.5, 0.5, delta)
	move_and_slide()


func set_group(new_group):
	group = new_group
	


func figure_eight(factor, delta):
	# Figure 8 movement
	#velocity = Vector2.ZERO
	angle += delta
	if angle > 2*PI:
		angle = 0
	global_position.x += (cos(angle))*factor*delta
	global_position.y += (pow(cos(angle), 2) - pow(sin(angle), 2))*factor*delta


func boids(separation_factor, cohesion_factor, delta):
	var separation_dx = 0
	var separation_dy = 0
	
	var cohesion_neighboring_boids = 0
	var cohesion_xpos_avg = 0
	var cohesion_ypos_avg = 0
	
	for bat in group:
		if weakref(bat).get_ref():
			if global_position.distance_to(bat.global_position) < 50: #this is magic
				separation_dx += global_position.x - bat.global_position.x
				separation_dy += global_position.y - bat.global_position.y
			
			cohesion_xpos_avg += bat.global_position.x
			cohesion_ypos_avg += bat.global_position.y
			cohesion_neighboring_boids += 1
	
	global_position.x += separation_dx*separation_factor*delta
	global_position.y += separation_dy*separation_factor*delta
	if(cohesion_neighboring_boids != 0):
		cohesion_xpos_avg = cohesion_xpos_avg/cohesion_neighboring_boids
		cohesion_ypos_avg = cohesion_ypos_avg/cohesion_neighboring_boids
	global_position.x += (cohesion_xpos_avg - global_position.x)*cohesion_factor*delta
	global_position.y += (cohesion_ypos_avg - global_position.y)*cohesion_factor*delta


func apply_damage(damage):
	hit_sound_player.stream = hit_sound
	hit_sound_player.play()
	sprite.set_modulate(Color(2, 0.1, 0.1))
	health -= damage
	if health <= 0:
		destroy()


func apply_knockback(direction, force = 10):
	velocity = Vector2(0,0)
	velocity += force * direction


func destroy():
	hit_sound_player.stream = death_sound
	hit_sound_player.play()
	destroyed = true
	set_collision_layer_value(2, false)
	sprite.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("default")
	#queue_free()


func set_player(player):
	self.player = player


func _on_explosion_sprite_animation_finished():
	explosion_sprite.visible = false
	queue_free()


func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		var player = body
		player.apply_damage(BODY_DAMAGE)
		player.apply_knockback(direction)


