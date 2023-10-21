extends State
class_name PlayerCrouch

@export var player: CharacterBody2D

func enter():
	player.player_sprite.play()

func exit():
	player.player_sprite.play()

# Called when the node enters the scene tree for the first time.
func physics_update(delta: float):
	if player.is_on_floor():
		player.velocity.x = move_toward(player.velocity.x, 0, delta*player.friction_factor)
		player.player_sprite.animation = "crouch"
		#player_sprite.frame = 0
		if Input.is_action_just_pressed("ui_accept"):
			player.velocity.y = player.JUMP_VELOCITY
			#exit_crouch_state()
