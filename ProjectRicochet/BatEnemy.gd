extends CharacterBody2D

var BASE_SPEED = 100

var health = 800

@onready var hitbox = $Hitbox
@onready var bat_sprite = $BatSprite
@onready var explosion_sprite = $ExplosionSprite
var group = []

var player = null
var root_node = null
var goal = null
var is_bat=true
var destroyed = false

var angle = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	explosion_sprite.visible = false
	root_node = get_tree().get_root().get_child(0)
	self.set_collision_layer_value(1, false)
	self.set_collision_mask_value(1, false)
	self.set_collision_layer_value(2, true)
	self.set_collision_mask_value(2, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not destroyed:
		step(delta)

func step(delta):
	bat_sprite.set_modulate(lerp(bat_sprite.get_modulate(), Color(1,1,1), delta*6)) 
	
	#print(group)
	if root_node.player:
		player = root_node.player
		
	if player:
		goal = player.global_position
		var distance = self.global_position.distance_to(goal)
		var dir = (player.global_position - self.global_position).normalized()
		#global_position += (dir * 10)
		if distance < 300:
			velocity += dir * 2
		else:
			velocity = lerp(velocity, dir * BASE_SPEED, delta*3)
		figure_eight(100, delta)
	#translate(velocity)
	boids(2, 0, delta)
	move_and_slide()


	
func set_group(new_group):
	self.group = new_group
	


func figure_eight(factor, delta):
	# Figure 8 movement
	#velocity = Vector2.ZERO
	self.angle += delta
	if angle > 2*PI:
		angle = 0
	self.global_position.x += (cos(angle))*factor*delta
	self.global_position.y += (pow(cos(angle), 2) - pow(sin(angle), 2))*factor*delta


func boids(separation_factor, cohesion_factor, delta):
	var separation_dx = 0
	var separation_dy = 0
	
	var cohesion_neighboring_boids = 0
	var cohesion_xpos_avg = 0
	var cohesion_ypos_avg = 0
	
	for bat in group:
		var wr = weakref(bat)
		if wr.get_ref():
			if self.global_position.distance_to(bat.global_position) < 50:
				separation_dx += self.global_position.x - bat.global_position.x
				separation_dy += self.global_position.y - bat.global_position.y
			
			cohesion_xpos_avg += bat.global_position.x
			cohesion_ypos_avg += bat.global_position.y
			cohesion_neighboring_boids += 1
	
	self.global_position.x += separation_dx*separation_factor*delta
	self.global_position.y += separation_dy*separation_factor*delta
	
	cohesion_xpos_avg = cohesion_xpos_avg/cohesion_neighboring_boids
	cohesion_ypos_avg = cohesion_ypos_avg/cohesion_neighboring_boids
	self.global_position.x += (cohesion_xpos_avg - self.global_position.x)*cohesion_factor*delta
	self.global_position.y += (cohesion_ypos_avg - self.global_position.y)*cohesion_factor*delta
	

func take_damage(damage):
	bat_sprite.set_modulate(Color(2, 0.1, 0.1))
	self.health -= damage
	if self.health <= 0:
		self.destroy()

func apply_force(force, direction):
	velocity = Vector2(0,0)
	velocity += force * direction

func destroy():
	destroyed = true
	self.set_collision_layer_value(2, false)
	bat_sprite.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("default")
	#queue_free()

func _on_explosion_sprite_animation_finished():
	explosion_sprite.visible = false
	queue_free()
