extends Node2D

class_name BatSpawner

@onready var Bat = preload("res://Scenes/Enemies/bat_enemy.tscn")

var SPAWN_COUNT = 5

@export var player : Player

func _ready():
	var rng = RandomNumberGenerator.new()
	var group = []
	for i in SPAWN_COUNT:

		var r1 = rng.randf_range(-50.0, 50.0)
		var r2 = rng.randf_range(-50.0, 50.0)
		var new_bat = Bat.instantiate()
		new_bat.add_to_group("avoid_bullet")
		new_bat.add_to_group("enemies")
		new_bat.global_position = self.global_position + Vector2(r1, r2)
		new_bat.set_player(player)
		group.append(new_bat)
	for bat in group:
		bat.set_group(group)
		get_tree().get_root().add_child.call_deferred(bat)
