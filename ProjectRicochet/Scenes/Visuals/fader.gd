extends Node2D

@export var activated : bool = false
@export var fade_in : bool = true
@export var fade_out : bool = true
@export var stay_time : int = 1
var alpha = 1.0
var timer : Timer = Timer.new()
var should_wait = true
signal finished


# Called when the node enters the scene tree for the first time.
func _ready():
	if fade_in:
		alpha = 0.0
	for child in get_children():
		child.visible = false
	timer.wait_time = stay_time
	timer.one_shot = true
	if activated:
		activate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var factor = 0.5
	if activated:
		if fade_in:
			alpha += delta * factor
			if alpha >= 1:
				await get_tree().create_timer(stay_time).timeout 
				fade_in = false
		elif fade_out:
			if should_wait:
				await get_tree().create_timer(stay_time).timeout 
				should_wait = false
			alpha -= delta * factor
			if alpha <= 0:
				finished.emit()
				
		for child in get_children():
			child.modulate.a = alpha


func activate():
	for child in get_children():
		child.visible = true
	activated = true
