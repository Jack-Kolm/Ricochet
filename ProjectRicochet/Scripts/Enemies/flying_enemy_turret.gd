extends "res://Scripts/Enemies/flying_enemy_base.gd"

const APPROACH_SPEED = 100
const BACKING_SPEED = 120
const UP_SPEED = -170
const BACKING_DELTA_FACTOR = 2

const APPROACH_DISTANCE = 180
const AWAY_DISTANCE = 150
const VERTICAL_DISTANCE = 80
@onready var shoot_timer = $ShootTimer
@onready var Bullet = preload("res://Scenes/Bullets/enemy_bullet.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	health = 300
	explosion_sprite = $ExplosionSprite
	sprite = $Sprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	super(delta)


func chase_step(delta):
	if weakref(player).get_ref():
		goal = player.global_position
		var distance = global_position.distance_to(goal)
		var direction_vector = (player.hitpoint() - global_position)
		direction = direction_vector.normalized()
		$Gun.rotation = global_position.angle_to_point(player.global_position)
		if direction_vector.y < VERTICAL_DISTANCE:
			velocity = lerp(velocity, Vector2(velocity.x, UP_SPEED), delta*BACKING_DELTA_FACTOR)
		elif distance < AWAY_DISTANCE:
			velocity = lerp(velocity, -direction * BACKING_SPEED, delta*BACKING_DELTA_FACTOR)
		elif distance < APPROACH_DISTANCE and distance > AWAY_DISTANCE:
			velocity = lerp(velocity, Vector2(0,0), delta*STATIONARY_DELTA_FACTOR)#Vector2(0,0)
		else:
			velocity = lerp(velocity, direction * APPROACH_SPEED, delta)
		if shoot_timer.is_stopped():
			shoot_timer.start()
		if direction.x > 0:
			$Sprite.scale.x = -1
			$Sprite.rotation = direction.angle()
		else:
			$Sprite.scale.x = 1
			$Sprite.rotation = direction.angle() - PI

func general_step(delta):
	super(delta)
	$Gun/GunSprite.set_modulate(lerp(sprite.get_modulate(), Color(1,1,1,1), delta*HURT_DELTA)) 

func shoot():
	var new_bullet = Bullet.instantiate()
	new_bullet.global_position = $Gun/BarrelPoint.global_position
	new_bullet.prepare(direction)
	get_tree().get_root().add_child(new_bullet)
	$ShootSound2D.play()

func destroy():
	super()
	$Gun.visible = false
	set_collision_layer_value(2, false)

func apply_damage(damage):
	super(damage)
	$Gun/GunSprite.set_modulate(Color(0.7, 1, 1, 0.7))


func _on_shoot_timer_timeout():
	shoot()

