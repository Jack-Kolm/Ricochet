extends "res://Scripts/Enemies/shield_enemy_base.gd"

class_name ChargingShieldEnemy


const SEPARATION_DELTA = 3
const SEPARATION_SPEED = 600

func _ready():
	super()
	damage = 100
	sprite = $EnemySprite
	explosion_sprite = $ExplosionSprite
	hurtbox_shape = $Hurtbox/HurtboxShape

func general_step(delta):
	super(delta)


func chase_step(delta):
	general_step(delta)
	if weakref(player).get_ref():
		var target_dist_x = player.global_position.x - global_position.x
		var target_dist_y = player.global_position.y - global_position.y
		movement_x_axis = player_x_axis
		if abs(target_dist_x) > STOP_CHASE_X and abs(target_dist_y) >  STOP_CHASE_Y:
			enter_state(States.ROAM)
		if turn_to_player_timer.is_stopped():
			if player_x_axis * facing_x_axis != 1:
				turn_to_player_timer.start()
		if not charging:
			var target_distance = global_position.distance_to(player.global_position)
			if abs(target_dist_x) < away_target_distance:
				velocity.x =  lerp(velocity.x, movement_x_axis * -SPEED, delta * MOVE_FACTOR)
				if $ChargeTimeout.is_stopped():
					charging = true
					$ChargeTimeout.start()
					$ChargeDuration.start()
			elif abs(target_dist_x) > away_target_distance and abs(target_dist_x) < toward_target_distance:
				velocity.x = lerp(velocity.x, 0.0, delta*STOP_FACTOR)
			else:
				velocity.x =  lerp(velocity.x, movement_x_axis * SPEED, delta * MOVE_FACTOR)
				
		else:
			velocity.x =  lerp(velocity.x, facing_x_axis*CHARGE_SPEED, delta * CHARGE_FACTOR)
	
	for ray in $SeparationNode.get_children():

		if ray.is_colliding() and ray.get_collider().is_in_group("enemies"):
				var move_away_x = -sign(global_position.direction_to(ray.get_collider().global_position).x)
				velocity.x = lerp(velocity.x, move_away_x*SEPARATION_SPEED, delta*SEPARATION_DELTA)


