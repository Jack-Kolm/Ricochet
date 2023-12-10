extends Node2D

signal activated

const ACTIVATED_MODULATE = Color(0, 255, 0)
const UNACTIVATED_MODULATE = Color(255, 255, 0)

@export var touchable = true
var is_activated = false

@onready var sprite = $Area2D/Sprite
@onready var fader = $MarginContainer/Fader
# Called when the node enters the scene tree for the first time.


func set_as_active():
	sprite.modulate = ACTIVATED_MODULATE
	is_activated = true

func set_as_inactive():
	sprite.modulate = UNACTIVATED_MODULATE

func _on_area_2d_body_entered(body):
	if body.is_in_group("player") and not is_activated and touchable:
		$ActivateSound.play()
		body.heal()
		fader.activate()
		activated.emit()
		set_as_active()
		

