"""
Children need (names too):
	CollisionBox
	Sprite
	SeparationArea
	Hurtbox
	PlayerDetection
	ExplosionSprite
	DeathTimer
"""

extends "res://Scripts/Enemies/base_enemy.gd"

class_name FlyingEnemyBase

const STATIONARY_DELTA_FACTOR = 5
const DEATH_MODULATE = Color(1,0.2,0.2)

enum States {ROAM, CHASE, DESTROYED}
var current_state = States.ROAM
var previous_state = States.CHASE

var direction = Vector2(0,0)
var goal = Vector2(0,0)

@export var aggro_start = false
@export var cohesive = true


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	death_delta = 1.5
	if aggro_start:
		current_state = States.CHASE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	super(delta)
	if destroyed and current_state != States.DESTROYED:
		enter_state(States.DESTROYED)
	match current_state:
		States.ROAM:
			roam_step(delta)
		States.CHASE:
			chase_step(delta)
		States.DESTROYED:
			death_step(delta)
	general_step(delta)
	boids_separation(delta)
	move_and_slide()

func enter_state(state):
	exit_state(current_state)
	match state:
		States.DESTROYED:
			sprite.modulate = DEATH_MODULATE
	current_state = state


func exit_state(state):
	previous_state = state


func roam_step(delta):
	velocity = lerp(velocity, Vector2(0,0), delta*STATIONARY_DELTA_FACTOR)


func chase_step(_delta):
	pass

func death_step(delta):
	super(delta)
	if not exploding:
		velocity.x = lerp(velocity.x, 0.0, delta*death_delta)
		rotation = lerp(rotation, PI, delta)



func boids_separation(delta):
	#var separation_distance = 1000
	var separation_factor = 2
	#var delta_factor = 1
	var separation_dx = 0.0
	var separation_dy = 0.0
	var should_separate = false
	
	var cohesion_neighboring_boids = 0
	var cohesion_xpos_avg = 0
	var cohesion_ypos_avg = 0
	var cohesion_factor = 1
	
	for body in $SeparationArea.get_overlapping_bodies():
		if body.is_in_group("enemies") and body != self:
			#if global_position.distance_to(body.global_position) < separation_distance:
			should_separate = true
			separation_dx += global_position.x - body.global_position.x
			separation_dy += global_position.y - body.global_position.y
	for body in $CohesionArea.get_overlapping_bodies():
		if body.is_in_group("enemies") and body != self:
			#if global_position.distance_to(body.global_position) < separation_distance:
			cohesion_xpos_avg += body.global_position.x
			cohesion_ypos_avg += body.global_position.y
			cohesion_neighboring_boids += 1
	#global_position.x += separation_dx*separation_factor*delta
	#global_position.y += separation_dy*separation_factor*delta
	#velocity.x += separation_dx*separation_factor*delta
	#velocity.y += separation_dy*separation_factor*delta
	if(cohesion_neighboring_boids != 0):
		cohesion_xpos_avg = cohesion_xpos_avg/cohesion_neighboring_boids
		cohesion_ypos_avg = cohesion_ypos_avg/cohesion_neighboring_boids
		var cohesion_velocity_x = (cohesion_xpos_avg - global_position.x)
		var cohesion_velocity_y = (cohesion_ypos_avg - global_position.y)
		velocity.x = move_toward(velocity.x, cohesion_velocity_x, delta*cohesion_factor)
		velocity.y = move_toward(velocity.y, cohesion_velocity_y, delta*cohesion_factor)
	if should_separate:
		velocity.x = lerp(velocity.x, separation_dx, delta*separation_factor)
		velocity.y = lerp(velocity.y, separation_dy, delta*separation_factor)
	#velocity.x += new_velocity_x
	#velocity.y += new_velocity_y


func apply_knockback(force, knockback_direction):
	velocity = Vector2(0,0)
	velocity += force * knockback_direction

func set_aggro_start(new_aggro_start : bool):
	self.aggro_start = new_aggro_start
	

func _on_player_detection_body_entered(body):
	if body.is_in_group("player"):
		current_state = States.CHASE

