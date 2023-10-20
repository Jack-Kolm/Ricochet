extends Node2D

const FADEOUT_DELTA = 1.5

enum EnemyTypes {CHARGER, TURRET, BAT}
@export var enemy_type : EnemyTypes

@onready var Turret = preload("res://Scenes/Enemies/flying_enemy.tscn")
@onready var ShieldCharger = preload("res://Scenes/Enemies/charging_shield_enemy.tscn")
@onready var Bat = preload("res://Scenes/Enemies/bat_enemy.tscn")

var fadeout = false
var player : Player

# Called when the node enters the scene tree for the first time.
func _ready():
	var root_node = get_tree().get_root().get_child(0)
	player = root_node.player
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fadeout:
		$SpawnSprite.set_modulate(lerp($SpawnSprite.get_modulate(), Color(10,0.3,0.3,0), delta*FADEOUT_DELTA)) 



func spawn():
	var new_enemy = null
	match enemy_type:
		EnemyTypes.TURRET:
			new_enemy = Turret.instantiate()
		EnemyTypes.CHARGER:
			new_enemy = ShieldCharger.instantiate()
			new_enemy.aggro()
			var x_axis = sign(global_position.direction_to(player.global_position).x)
			if x_axis < 0:
				new_enemy.face_right_at_start = false
		_:
			new_enemy = Bat.instantiate()
	visible = true
	new_enemy.add_to_group("enemies")
	new_enemy.global_position = global_position
	get_tree().get_root().add_child.call_deferred(new_enemy)
	$SpawnSprite.play()
	fadeout = true
	$SpawnSound.play()
	return new_enemy

func set_sprite_rotation(angle):
	$SpawnSprite.rotation = angle

func _on_activate_spawn_area_body_entered(body):
	spawn()


func _on_spawn_sprite_animation_finished():
	visible = false
	$DestructTimer.start()


func _on_destruct_timer_timeout():
	queue_free()

