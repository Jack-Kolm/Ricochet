extends State
class_name PlayerIdle

@export var player: CharacterBody2D


# Called when the node enters the scene tree for the first time.
func physics_update(delta: float):
	if player.direction:
		player.velocity.x = lerp(player.velocity.x, player.direction * player.SPEED, delta*5)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, delta*player.friction_factor)
	if player.is_on_floor():
		if player.direction:
			player.player_sprite.animation = "walk"
		else:
			player.player_sprite.animation = "idle"
		if Input.is_action_just_pressed("ui_accept"):
			player.velocity.y = player.JUMP_VELOCITY
