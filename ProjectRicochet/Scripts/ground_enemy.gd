extends CharacterBody2D

class_name GroundEnemy

var health
var friction
var x_axis

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func apply_damage(damage):
	pass

func apply_knockback(direction, force=0):
	pass

func destroy():
	pass
