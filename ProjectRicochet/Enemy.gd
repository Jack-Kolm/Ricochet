extends CharacterBody2D

class_name Enemy

var health = 400


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func apply_damage(damage, direction=Vector(0,0), force=0):
	pass

func apply_force(direction, force=0):
	pass

func destroy():
	pass
