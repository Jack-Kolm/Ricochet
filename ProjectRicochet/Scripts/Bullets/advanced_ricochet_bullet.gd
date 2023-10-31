extends CharacterBody2D

const SPEED = 1220
const MAX_BOUNCES = 6
const BASE_DAMAGE = 100
const KNOCKBACK_FACTOR = 100

@onready var bullet_sprite = $BulletSprite
@onready var destruction_timer = $DestructionTimer
@onready var explosion_sprite = $ExplosionSprite
@onready var animation_player = $AnimationPlayer
@onready var sound_player = $RicochetSoundPlayer2D
@onready var ricochet_timer = $RicochetTimer
@onready var destruction_delay_timer = $DestructionDelayTimer
@onready var hitbox = $Hitbox
var direction = Vector2(0, 0)
var bounces = 0
var should_bounce = false
var damage = BASE_DAMAGE
var destroyed = false

var hitstop_flag = false
var hitstop_time = 0

var rng = RandomNumberGenerator.new()

var trace_colors = [Color(0.7, 0.7, 0.7), 
				Color(0.7, 0.7, 1),
				Color(0.4, 0.6, 1),
				Color(0.3, 0.0, 0.7),
				Color(0.6, 0.0, 1.0),
				Color(0.75, 0, 1.0),
				Color(1.0, 0, 1.0),
				Color(1.0, 0.0, 0.8),]

var impact1 = preload("res://Sounds/Impact/metal_solid_impact_bullet1.wav")
var impact2 = preload("res://Sounds/Impact/metal_solid_impact_bullet2.wav")
var impact3 = preload("res://Sounds/Impact/metal_solid_impact_bullet3.wav")
var impact4 = preload("res://Sounds/Impact/metal_solid_impact_bullet4.wav")
var impact_sounds = [impact1, impact2, impact3, impact4]

var HitEffect = preload("res://Scenes/Visuals/hit_effect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("ricochet_bullets")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	$Trace.default_color = trace_colors[bounces]
	if hitstop_flag:
		hitstop_time += delta
		if hitstop_time > 0.03:
			hitstop_flag = false
			Engine.time_scale = 1
	if destroyed:
		return
	direction = velocity.normalized()
	rotation = direction.angle() - PI/2
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		if not collision_info.get_collider().is_in_group("avoid_bullet"):
			ricochet(collision_info.get_normal())


func ricochet(normal):
	#if ricochet_timer.is_stopped():
	velocity = velocity.bounce(normal)
	bounces += 1
	if bullet_sprite.frame < MAX_BOUNCES:
		bullet_sprite.frame += 1
	if bounces >= MAX_BOUNCES:
		play_ricochet_sound()
		destroy()
	else:
		#velocity = velocity + velocity*0.1 #speed increase
		damage = BASE_DAMAGE * bounces
		bullet_sprite.set_modulate(Color(1, 1, 1, 1))
		play_ricochet_sound()
		#ricochet_timer.start()


func play_ricochet_sound():
	var index = rng.randi_range(0, 3)
	sound_player.stream = impact_sounds[index]
	sound_player.play()
	#sound_player.volume_db += 3
	sound_player.pitch_scale += 0.3


func check_enemy(body):
	if body.is_in_group("enemies"):
		if body.destroyed:
			return
		if bounces > 0:
			var enemy = body
			print(enemy.name)
			enemy.apply_damage(damage)
			enemy.apply_knockback(KNOCKBACK_FACTOR*bounces, direction)
			var hit_effect = HitEffect.instantiate()
			hit_effect.global_position = global_position
			get_tree().get_root().add_child.call_deferred(hit_effect)
			#Global.delta_factor = 0.01
			hitstop_flag = true
			Engine.time_scale = 0.1
			$HitSoundPlayer2D.play()
			#$HitstopTimer.start()
		else:
			$BadHitSoundPlayer2D.play()
		destroy()


func prepare(start_direction):
	direction = start_direction
	velocity = start_direction * SPEED


func destroy():
	destroyed = true
	#$Trace.visible = false
	hitbox.set_collision_layer_value(2, false)
	hitbox.set_collision_mask_value(3, false)
	set_collision_layer_value(2, false)
	set_collision_mask_value(3, false)
	bullet_sprite.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("default")


func get_direction():
	return direction

func get_bounces():
	return bounces

func _on_destruction_timer_timeout():
	destroy()
	#queue_free()


func _on_explosion_sprite_animation_finished():
	explosion_sprite.visible = false
	destruction_delay_timer.start()


func _on_hitbox_area_entered(area):
	check_enemy(area.get_owner())


func _on_destruction_delay_timer_timeout():
	queue_free()



func _on_hitstop_timer_timeout():
	Engine.time_scale = 1
