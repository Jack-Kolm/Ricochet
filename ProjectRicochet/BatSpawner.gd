extends Node2D

@onready var Bat = preload("res://bat_enemy.tscn")

var SPAWN_COUNT = 5
func _ready():
	var rng = RandomNumberGenerator.new()
	var group = []
	for i in SPAWN_COUNT:

		var r1 = rng.randf_range(-50.0, 50.0)
		var r2 = rng.randf_range(-50.0, 50.0)
		var new_bat = Bat.instantiate()
		new_bat.add_to_group("enemies")
		new_bat.global_position = self.global_position + Vector2(r1, r2)
		
		var root_node = get_tree().get_root().get_child(0)
		if weakref(root_node).get_ref():
			if weakref(root_node.player).get_ref():
				new_bat.set_player(root_node.player)
		group.append(new_bat)
	for bat in group:
		bat.set_group(group)
		get_tree().get_root().add_child.call_deferred(bat)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
