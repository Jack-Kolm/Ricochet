"""
Children need (names too):
	CollisionBox
	Sprite
	SeparationArea
	HurtboxArea
	PlayerDetection
	ExplosionSprite
"""

extends "res://Scripts/Enemies/base_enemy.gd"

class_name FlyingEnemyBase

enum States {ROAM, CHASE}
var current_state = States.ROAM

const STATIONARY_DELTA_FACTOR = 5

var direction = Vector2(0,0)
var goal = Vector2(0,0)

@export var aggro_start = false

@onready var separation_area = $SeparationArea


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	if aggro_start:
		current_state = States.CHASE



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	super(delta)
	if destroyed:
		return
	match current_state:
		States.ROAM:
			roam_step(delta)
		States.CHASE:
			chase_step(delta)
	boids_separation(delta)
	move_and_slide()


func roam_step(delta):
	velocity = lerp(velocity, Vector2(0,0), delta*STATIONARY_DELTA_FACTOR)#Vector2(0,0)


func chase_step(delta):
	pass


func boids_separation(delta):
	var separation_distance = 1000
	var separation_factor = 1
	var delta_factor = 1
	var separation_dx = 0.0
	var separation_dy = 0.0
	var should_separate = false
	for body in separation_area.get_overlapping_bodies():
		if body.is_in_group("enemies") and body != self:
			#if global_position.distance_to(body.global_position) < separation_distance:
			should_separate = true
			separation_dx += global_position.x - body.global_position.x
			separation_dy += global_position.y - body.global_position.y
	#global_position.x += separation_dx*separation_factor*delta
	#global_position.y += separation_dy*separation_factor*delta
	#velocity.x += separation_dx*separation_factor*delta
	#velocity.y += separation_dy*separation_factor*delta
	if should_separate:
		velocity.x = lerp(velocity.x, separation_dx*separation_factor, delta*delta_factor)
		velocity.y = lerp(velocity.y, separation_dy*separation_factor, delta*delta_factor)


func apply_knockback(force, direction):
	velocity = Vector2(0,0)
	velocity += force * direction

func set_aggro_start(aggro_start : bool):
	self.aggro_start = aggro_start
	

func _on_player_detection_body_entered(body):
	if body.is_in_group("player"):
		current_state = States.CHASE

