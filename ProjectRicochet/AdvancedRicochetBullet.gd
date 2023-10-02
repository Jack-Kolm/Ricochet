extends CharacterBody2D

const MAX_BOUNCES = 6
const BASE_DAMAGE = 100
@onready var bullet_sprite = $BulletSprite
@onready var timer = $DestructionTimer
@onready var explosion_sprite = $ExplosionSprite
@onready var animation_player = $AnimationPlayer
@onready var sound_player = $RicochetSoundPlayer2D

var dir = Vector2(0, 0)
var bounces = 0
var should_bounce = false
var damage = BASE_DAMAGE
var destroyed = false
var has_bounced = false

var rng = RandomNumberGenerator.new()
var impact1 = preload("res://Sounds/Impact/metal_solid_impact_bullet1.wav")
var impact2 = preload("res://Sounds/Impact/metal_solid_impact_bullet2.wav")
var impact3 = preload("res://Sounds/Impact/metal_solid_impact_bullet3.wav")
var impact4 = preload("res://Sounds/Impact/metal_solid_impact_bullet4.wav")
var impact_sounds = [impact1, impact2, impact3, impact4]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if destroyed:
		return
	dir = velocity.normalized()
	var angle = dir.angle_to(dir*5)
	self.rotation = dir.angle() + PI/2
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		if not collision_info.get_collider().is_in_group("avoid_bullet"):
			velocity = velocity.bounce(collision_info.get_normal())
			bounces += 1
			if bullet_sprite.frame < 6:
				bullet_sprite.frame += 1
			if bounces >= MAX_BOUNCES:
				destroy() #destroy function here later
			should_bounce = true
			has_bounced = true
	if should_bounce:
		velocity = velocity + velocity*0.1
		damage = BASE_DAMAGE * bounces
		bullet_sprite.set_modulate(Color(1, 1, 1, 1))
		var index = rng.randi_range(0, 3)
		sound_player.stream = impact_sounds[index]
		sound_player.play()
		sound_player.volume_db += 3
		sound_player.pitch_scale += 0.3
		should_bounce = false


func check_enemy(body):
	if has_bounced:
		if body.is_in_group("enemies"):
			var bat = body
			bat.take_damage(damage)
			bat.apply_force(100*bounces, dir)
			self.destroy()


func prepare(new_velocity):
	self.velocity = new_velocity


func destroy():
	destroyed = true
	self.set_collision_layer_value(2, false)
	self.set_collision_mask_value(2, false)
	bullet_sprite.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("default")
	queue_free()


func _on_destruction_timer_timeout():
	destroy()
	#queue_free()


func _on_explosion_sprite_animation_finished():
	explosion_sprite.visible = false
	queue_free()


func _on_hitbox_area_entered(area):
	check_enemy(area.get_owner())

