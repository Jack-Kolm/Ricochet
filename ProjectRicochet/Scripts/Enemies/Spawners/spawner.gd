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
func _process(delta):
	#delta = delta * Global.delta_factor
	if has_completed:
		cleanup()
	elif not has_completed and has_spawned and spawned_enemies <= 0:
		has_completed = true
		completed.emit()


func cleanup():
	for enemy_spawn in $Spawns.get_children():
		enemy_spawn.queue_free()
	queue_free() 

	
func _on_activate_spawn_area_body_exited(body):
	if body.is_in_group("player") and not has_spawned:
		activated.emit()
		
		player = body
		var angle = PI
		var rng = RandomNumberGenerator.new()
		var angle_variation = rng.randf_range(0.0, 2.0)
		spawned_enemies = $Spawns.get_child_count()
		for enemy_spawn in $Spawns.get_children():
			enemy_spawn.spawner = self
			enemy_spawn.set_player(player)
			#enemy_spawn.set_sprite_rotation(angle_variation*angle)
			var enemy = enemy_spawn.spawn()
			
			if bat_boss_flag:
				total_health += enemy.health
				enemy.boss_scene = get_parent()
				enemy.jump_spots = get_tree().get_root().get_node("BossLevel").get_node("JumpSpots")
				#enemy.jump_points = $../JumpPoints
			await get_tree().create_timer(spawn_delay).timeout
		if bat_boss_flag:
			get_parent().boss_health = float(total_health)
			get_parent().engage_boss()
		has_spawned = true
