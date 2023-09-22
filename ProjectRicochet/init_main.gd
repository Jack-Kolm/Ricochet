extends Node2D

@onready var player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func a_simple_test():
	print("HALLÅ!")

func set_player(player):
	self.player = player


func _on_game_area_body_exited(body):
	
	pass # Replace with function body.
