extends Node2D

const FADEOUT_DELTA = 1.5

enum EnemyTypes {CHARGER, SHIELD_CHARGER, TURRET, BAT, BOSS}

@export var enemy_type : EnemyTypes
@onready var Turret = preload("res://Scenes/Enemies/flying_enemy_turret.tscn")
@onready var ShieldCharger = preload("res://Scenes/Enemies/shield_enemy_charger.tscn")
@onready var Bat = preload("res://Scenes/Enemies/bat_enemy.tscn")
@onready var Boss = preload("res://nav_char.tscn")

var fadeout = false
var player : Player
var spawner : Spawner


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#delta = delta * Global.delta_factor
	if fadeout:
		$SpawnSprite.set_modulate(lerp($SpawnSprite.get_modulate(), Color(10,0.3,0.3,0), delta*FADEOUT_DELTA)) 


func spawn():
	var new_enemy = null
	match enemy_type:
		EnemyTypes.TURRET:
			new_enemy = Turret.instantiate()
			new_enemy.aggro_start = true
		EnemyTypes.SHIELD_CHARGER:
			new_enemy = ShieldCharger.instantiate()
			new_enemy.aggro()
			var x_axis = sign(global_position.direction_to(player.global_position).x)
			if x_axis < 0:
				new_enemy.face_right_at_start = false
			new_enemy.has_shield = true
		EnemyTypes.CHARGER:
			new_enemy = ShieldCharger.instantiate()
			new_enemy.aggro()
			var x_axis = sign(global_position.direction_to(player.global_position).x)
			if x_axis < 0:
				new_enemy.face_right_at_start = false
		EnemyTypes.BAT:
			new_enemy = Bat.instantiate()
			new_enemy.aggro_start = true
		EnemyTypes.BOSS:
			new_enemy = Boss.instantiate()
			new_enemy.player = player
		_:
			new_enemy = Bat.instantiate()
	$SpawnSprite.visible = true
	new_enemy.spawner = self.spawner
	#new_enemy.add_to_group("enemies")
	new_enemy.global_position = global_position
	get_parent().add_child.call_deferred(new_enemy)
	get_tree().get_root().add_child.call_deferred(new_enemy)
	$SpawnSprite.play()
	fadeout = true
	$SpawnSound.play()
	return new_enemy


func set_player(player):
	self.player = player


func set_sprite_rotation(angle):
	$SpawnSprite.rotation = angle


func _on_activate_spawn_area_body_entered(body):
	spawn()


func _on_spawn_sprite_animation_finished():
	visible = false
	$DestructTimer.start()


func _on_destruct_timer_timeout():
	queue_free()

