extends CharacterBody2D

class_name BaseEnemy


const HURT_DELTA = 1
const EXPLOSION_FADE_DELTA = 2

var health = 200
var destroyed = false
var exploding = false
var root_node = null
var player = null
var spawner : Spawner = null

@onready var sprite : AnimatedSprite2D
@onready var explosion_sprite : AnimatedSprite2D
@onready var hurtbox_shape

var death_delta = 8




# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("enemies")
	player = get_tree().get_nodes_in_group("player")[0]
	root_node = get_tree().get_root().get_child(0)
	#player = root_node.player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var hello = true

func general_step(delta):
	sprite.set_modulate(lerp(sprite.get_modulate(), Color(1,1,1,1), delta*HURT_DELTA)) 

func death_step(delta):
	sprite.set_modulate(Color(0.25, 1, 1, 0.45))
	if exploding:
		velocity = Vector2(0,0)
		explosion_sprite.modulate.a = lerp(explosion_sprite.modulate.a, 0.0, delta*EXPLOSION_FADE_DELTA)

func apply_damage(damage):
	sprite.set_modulate(Color(0.7, 1, 1, 0.7))
	health -= damage
	if health <= 0:
		destroy()


func destroy():
	#if not destroyed:
	destroyed = true
	if spawner != null:
		spawner.spawned_enemies -= 1
	#self.modulate.a = 0.4
	$DeathTimer.start()
	$Hitbox.monitoring = false


func _on_explosion_sprite_animation_finished():
	explosion_sprite.visible = false
	queue_free()


func _on_death_timer_timeout():
	sprite.visible = false
	sprite.stop()
	explosion_sprite.visible = true
	explosion_sprite.play("default")
	$DespawnSound2D.play()
	exploding = true

