extends Node

var spawned_enemies = []
var has_spawned = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(spawned_enemies)
	if has_spawned and spawned_enemies.is_empty():
		print("YOU DID IT")


func _on_activate_spawn_area_body_entered(body):
	for spawner in $Spawners.get_children():
		var enemy = spawner.spawn()
		spawned_enemies.append(enemy)
		await get_tree().create_timer(1).timeout
	has_spawned = true
