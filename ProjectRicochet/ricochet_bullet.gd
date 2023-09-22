extends Area2D

var BASE_DAMAGE = 200

var current_damage

@onready var bullet_cast = $BulletCast
@onready var timer = $DestructionTimer
@onready var bullet_sprite = $BulletSprite
@onready var explosion_sprite = $ExplosionSprite
@onready var animation_player = $AnimationPlayer

@onready var speed = 0
@onready var direction = Vector2(0,0)
@onready var points = []

@onready var should_bounce = false
@onready var current_goal = null
@onready var next_point = null
var bounces = 0
var max_bounces = null
var destroyed = false
# Called when the node enters the scene tree for the first time.
func _ready():
	current_damage = BASE_DAMAGE
	explosion_sprite.visible = false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not destroyed:
		self.step(delta)
func step(delta):
	
	if should_bounce and points.is_empty() == false:
		current_goal = points.pop_front()
		next_point = current_goal[0]
		#print(current_goal)
		direction = global_position.direction_to(next_point)
		should_bounce = false
	if global_position.distance_to(next_point) < 15:
		bounces += 1
		current_damage = BASE_DAMAGE * bounces
		if bullet_sprite.frame < 6:
			bullet_sprite.frame += 1
		speed += 1
		
		if bounces >= max_bounces:
			destroy()
		
		if current_goal[1]:
			if bounces > 1:
				var enemy = current_goal[1]
				var wr = weakref(enemy)
				#if wr.get_ref():
					#enemy.death()
			#destroy()
		should_bounce = true
	global_position += (direction * speed) #+ Vector2(10,0) 
	rotation = direction.angle() - (PI/2)


func prepare_bullet(new_speed, travel_points, start_spot):
	self.speed = new_speed
	self.points = travel_points
	self.max_bounces = travel_points.size()
	self.current_goal = self.points.pop_front()
	self.next_point = self.current_goal[0]
	self.direction = start_spot.direction_to(self.next_point)
	self.should_bounce = false

func destroy():
	destroyed = true
	self.set_collision_layer_value(2, false)
	self.set_collision_mask_value(2, false)
	bullet_sprite.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("default")
	#queue_free()

func _on_destruction_timer_timeout():
	#destroy()
	queue_free()


func _on_body_entered(body):
	if bounces > 0:
		if body.is_in_group("enemies"):
			var bat = body
			bat.take_damage(current_damage)
			bat.apply_force(100*bounces, direction)
			self.destroy()



func _on_explosion_sprite_animation_finished():
	explosion_sprite.visible = false
	queue_free()
	pass # Replace with function body.
