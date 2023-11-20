extends ShieldEnemyBase
class_name GunningShieldEnemy

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	health = 400
	damage = 200

# Called every frame. 'delta' is the elapsed time since the previous frame.
func chase_step(delta):
	general_step(delta)
	if weakref(player).get_ref():
		var target_x = player.global_position.x - global_position.x
		var target_y = player.global_position.y - global_position.y
		movement_x_axis = player_x_axis
		if abs(target_x) > STOP_CHASE_X or abs(target_y) >  STOP_CHASE_Y:
			enter_state(States.ROAM)
		if turn_to_player_timer.is_stopped():
			if player_x_axis * facing_x_axis != 1:
				turn_to_player_timer.start()
			var target_distance = global_position.distance_to(player.global_position)
			if abs(target_x) < away_target_distance:
				velocity.x =  lerp(velocity.x, movement_x_axis * -SPEED, delta * MOVE_FACTOR)
			elif abs(target_x) > away_target_distance and abs(target_x) < toward_target_distance:
				velocity.x = lerp(velocity.x, 0.0, delta*STOP_FACTOR)
			else:
				velocity.x =  lerp(velocity.x, movement_x_axis * SPEED, delta * MOVE_FACTOR)



