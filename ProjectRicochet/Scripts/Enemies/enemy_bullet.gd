extends CharacterBody2D



const BASE_DAMAGE = 100

var damage = BASE_DAMAGE
var direction = Vector2(0,0)
var speed = 200.0

@onready var bullet_sprite = $BulletSprite
@onready var timer = $DestructionTimer
@onready var explosion_sprite = $ExplosionSprite
@onready var animation_player = $AnimationPlayer

func _ready():
	pass

func _physics_process(delta):
	delta = delta * Global.delta_factor
	self.rotation = direction.angle() - PI/2
	var collision_info = move_and_collide(velocity * delta)
	#if collision_info:
	#	if collision_info.get_collider().is_in_group("player"):
	#		pass

func prepare(start_direction):
	self.direction = start_direction
	self.velocity = start_direction * speed

func destroy():
	queue_free()

func _on_hitbox_body_entered(body):
	#if body.name == "Player":
	#	var player = body
	#	player.apply_damage(damage, direction)
	#	self.destroy()
	pass


func _on_destruction_timer_timeout():
	destroy()



func _on_hitbox_area_entered(area):
	if area.get_owner().name == "Player":
		var player = area.get_owner()
		player.apply_knockback(direction)
		player.apply_damage(damage)
		self.destroy()

