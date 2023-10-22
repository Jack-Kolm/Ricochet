extends Node

class_name Spawner

@export var player : Player

var spawned_enemies = 0
var has_spawned = false
var has_completed = false

signal completed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#delta = delta * Global.delta_factor
	if has_completed:
		cleanup()
	elif not has_completed and has_spawned and spawned_enemies <= 0:
		has_completed = true
		completed.emit()


func cleanup():
	for enemy_spawn in $Spawners.get_children():
		enemy_spawn.queue_free()
	queue_free() 

func _on_activate_spawn_area_body_entered(body):
	var angle = PI
	var rng = RandomNumberGenerator.new()
	var angle_variation = rng.randf_range(0.0, 2.0)
	for enemy_spawn in $Spawners.get_children():
		enemy_spawn.spawner = self
		enemy_spawn.set_player(player)
		enemy_spawn.set_sprite_rotation(angle_variation*angle)
		var enemy = enemy_spawn.spawn()
		spawned_enemies += 1
		await get_tree().create_timer(1).timeout
	has_spawned = true
