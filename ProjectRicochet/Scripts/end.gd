extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Engine.time_scale = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$CanvasLayer/VBox/Label.modulate.a = lerp($CanvasLayer/VBox/Label.modulate.a, 1.0, delta)
	if $CanvasLayer/VBox/Label.modulate.a > 0.9:
		$CanvasLayer/VBox/Label2.modulate.a = lerp($CanvasLayer/VBox/Label2.modulate.a, 1.0, delta)
	if $CanvasLayer/VBox/Label2.modulate.a > 0.9:
		$CanvasLayer/VBox/Label3.modulate.a = lerp($CanvasLayer/VBox/Label3.modulate.a, 1.0, delta)
