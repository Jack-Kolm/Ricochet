extends "res://Scripts/Enemies/shield_enemy_base.gd"

class_name ChargingShieldEnemy


func _ready():
	super()
	damage = 100
	health = 50
	sprite = $EnemySprite
	explosion_sprite = $ExplosionSprite

func chase_step(delta):
	general_step(delta)
	if weakref(player).get_ref():
		var target_x = player.global_position.x - global_position.x
		var target_y = player.global_position.y - global_position.y
		movement_x_axis = player_x_axis
		if abs(target_x) > STOP_CHASE_X and abs(target_y) >  STOP_CHASE_Y:
			enter_state(States.ROAM)
		if turn_to_player_timer.is_stopped():
			if player_x_axis * facing_x_axis != 1:
				turn_to_player_timer.start()
		if not charging:
			var target_distance = global_position.distance_to(player.global_position)
			
			if target_x < away_target_distance:
				velocity.x =  lerp(velocity.x, movement_x_axis * -SPEED, delta * MOVE_FACTOR)
				if $ChargeTimeout.is_stopped():
					charging = true
					$ChargeTimeout.start()
					$ChargeDuration.start()
			elif target_x > away_target_distance and target_x < toward_target_distance:
				velocity.x = lerp(velocity.x, 0.0, delta*STOP_FACTOR)
			else:
				velocity.x =  lerp(velocity.x, movement_x_axis * SPEED, delta * MOVE_FACTOR)
		else:
			velocity.x =  lerp(velocity.x, facing_x_axis*CHARGE_SPEED, delta * CHARGE_FACTOR)

