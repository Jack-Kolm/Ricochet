extends CharacterBody2D

class_name BaseEnemy

var health = 800
var destroyed = false
var root_node = null
var player = null
var spawner : Spawner = null

@onready var sprite
@onready var explosion_sprite



# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	root_node = get_tree().get_root().get_child(0)
	#player = root_node.player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	delta = delta * Global.delta_factor


func apply_damage(damage):
	health -= damage
	if health <= 0:
		destroy()


func destroy():
	sprite.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("default")
	destroyed = true
	if spawner != null:
		spawner.spawned_enemies -= 1


func _on_explosion_sprite_animation_finished():
	explosion_sprite.visible = false
	queue_free()
