extends "res://Scripts/Enemies/flying_enemy_base.gd"

const BASE_SPEED = 80
const CHARGE_SPEED = 220
const CHARGE_DISTANCE = 170
const BODY_DAMAGE = 100
const GOAL_DELTA = 2

@onready var collision_box = $CollisionBoxShape
@onready var hitbox_shape = $Hitbox/Shape


var group = []
var is_bat=true
var angle = 0

var boss_scene = null
var jump_spots = null

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, false)
	health = 200
	explosion_sprite = $ExplosionSprite
	sprite = $Sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	super(delta)
	if not $WingSound.is_playing():
		$WingSound.play()

func chase_step(delta):
	if weakref(player).get_ref():
		goal = player.hitpoint()
		var distance = global_position.distance_to(goal)
		direction = global_position.direction_to(goal)
		#global_position += (direction * 10)
		if distance < CHARGE_DISTANCE:
			velocity = lerp(velocity, direction * CHARGE_SPEED, delta)
		else:
			velocity.x = lerp(velocity.x, direction.x * BASE_SPEED, delta*GOAL_DELTA)
			velocity.y = lerp(velocity.y, direction.y * BASE_SPEED, delta*GOAL_DELTA)
		figure_eight(100, delta)
	#translate(velocity)
	#batboids(0.5, 0.5, delta)

func set_group(new_group):
	group = new_group
	

func figure_eight(factor, delta):
	# Figure 8 movement
	#velocity = Vector2.ZERO
	angle += delta
	if angle > 2*PI:
		angle = 0
	global_position.x += (cos(angle))*factor*delta
	global_position.y += (pow(cos(angle), 2) - pow(sin(angle), 2))*factor*delta


func batboids(separation_factor, cohesion_factor, delta):
	var separation_dx = 0
	var separation_dy = 0
	
	var cohesion_neighboring_boids = 0
	var cohesion_xpos_avg = 0
	var cohesion_ypos_avg = 0
	
	for bat in group:
		if weakref(bat).get_ref():
			if global_position.distance_to(bat.global_position) < 50: #this is magic
				separation_dx += global_position.x - bat.global_position.x
				separation_dy += global_position.y - bat.global_position.y
			
			cohesion_xpos_avg += bat.global_position.x
			cohesion_ypos_avg += bat.global_position.y
			cohesion_neighboring_boids += 1
	
	global_position.x += separation_dx*separation_factor*delta
	global_position.y += separation_dy*separation_factor*delta
	if(cohesion_neighboring_boids != 0):
		cohesion_xpos_avg = cohesion_xpos_avg/cohesion_neighboring_boids
		cohesion_ypos_avg = cohesion_ypos_avg/cohesion_neighboring_boids
	global_position.x += (cohesion_xpos_avg - global_position.x)*cohesion_factor*delta
	global_position.y += (cohesion_ypos_avg - global_position.y)*cohesion_factor*delta

func destroy():
	super()
	set_collision_layer_value(2, false)


func set_player(new_player):
	self.player = new_player


func _on_explosion_sprite_animation_finished():
	explosion_sprite.visible = false
	queue_free()


func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		var player_body = body
		player_body.apply_knockback(direction)
		player_body.apply_damage(BODY_DAMAGE)

func apply_damage(damage):
	if boss_scene != null:
		if damage < health:
			boss_scene.boss_health -= damage
		else:
			boss_scene.boss_health -= health
	super(damage)
