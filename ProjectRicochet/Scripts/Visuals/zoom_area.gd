extends Node2D

const CLOSE_ZOOM = 4.7
const NORMAL_ZOOM = 3.0
const FAR_ZOOM = 1.6

@export var zoom_scale : float = 1.0
@export var zoom_delta : float = 1.0

#var directions = {"Up":Vector2(0,-1), "Down":Vector2(0,1), "Right":Vector2(1,0), "Left":Vector2(-1,0)}

enum Directions {ABOVE, BELOW, LEFT, RIGHT}

@export var entrance_dir : Directions

var previous_zoom_scale = 1.0
var first_enter = true
var enter_switch = 1

signal entered

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_zoom_area_body_exited(body):
	if body.is_in_group("player"):
		var player : Player = body
		var diff = (player.global_position - global_position) * enter_switch
		var previous_vals
		var success = false
		match entrance_dir:
			Directions.ABOVE:
				if diff.y > 0.0:
					success = true
			Directions.BELOW:
				if diff.y < 0.0:
					success = true
			Directions.RIGHT:
				if diff.x < 0.0:
					success = true
			Directions.LEFT:
				if diff.x > 0.0:
					success = true
		if success:
			if first_enter:
				entered.emit()
				first_enter = false
			previous_vals = player.change_camera_zoom(zoom_scale, zoom_delta)
			enter_switch *= -1
			zoom_scale = previous_vals[0]
			zoom_delta = previous_vals[1]

