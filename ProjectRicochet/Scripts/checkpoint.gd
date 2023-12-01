extends Node2D

signal activated

const ACTIVATED_MODULATE = Color(0, 255, 0)
const UNACTIVATED_MODULATE = Color(255, 255, 0)

@export var touchable = true
var is_activated = false


# Called when the node enters the scene tree for the first time.


func set_as_active():
	$Sprite.modulate = ACTIVATED_MODULATE
	is_activated = true

func set_as_inactive():
	$Sprite.modulate = UNACTIVATED_MODULATE

func _on_area_2d_body_entered(body):
	if body.is_in_group("player") and not is_activated and touchable:
		$Sprite.modulate = ACTIVATED_MODULATE
		body.heal()
		$Fader.activate()
		activated.emit()

