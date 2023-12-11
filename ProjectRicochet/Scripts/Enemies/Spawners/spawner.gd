extends Node2D

class_name Spawner

var player : Player

@export var spawn_delay = 0.7
@export var bat_boss_flag = false

var spawned_enemies = 0
var total_health = 0
var has_spawned = false
var has_completed = false

signal activated
signal completed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if has_completed:
		await completed
		cleanup()
	elif not has_completed and has_spawned and spawned_enemies <= 0:
		completed.emit()
		has_completed = true


func cleanup():
	for enemy_spawn in $Spawns.get_children():
		enemy_spawn.queue_free()
	queue_free() 

	
func _on_activate_spawn_area_body_exited(body):
	if body.is_in_group("player") and not has_spawned:
		activated.emit()
		player = body
		#var rng = RandomNumberGenerator.new()
		spawned_enemies = $Spawns.get_child_count()
		for enemy_spawn in $Spawns.get_children():
			enemy_spawn.spawner = self
			enemy_spawn.set_player(player)
			var enemy = enemy_spawn.spawn()
			if bat_boss_flag:
				total_health += enemy.health
				enemy.boss_scene = get_parent()
				enemy.jump_spots = get_tree().get_root().get_node("BossLevel").get_node("JumpSpots")
			await get_tree().create_timer(spawn_delay).timeout
		if bat_boss_flag:
			get_parent().boss_health = float(total_health)
			get_parent().engage_boss()
		has_spawned = true
