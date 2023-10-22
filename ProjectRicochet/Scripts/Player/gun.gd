extends StaticBody2D

class_name Gun

const RECOIL_DELTA = 1.5

@onready var raycast = $GunRayCast
@onready var tip_box = $GunTipBox

@onready var AdvancedBullet = preload("res://Scenes/Bullets/advanced_ricochet_bullet.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	#raycast.global_position = self.global_position;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	delta = delta * Global.delta_factor
	self.position = lerp(self.position, Vector2(0.0, -8.0), delta*RECOIL_DELTA)
	look_at(get_global_mouse_position())
	self.rotation = self.rotation - (PI/2)
	#raycast.rotation = self.rotation

func get_raycast():
	return raycast

func is_tip_colliding():
	if raycast.is_colliding():
		return true
	else:
		return false

func get_tip_global_position():
	return tip_box.global_position

func shoot():
	if not $GunRayCast.is_tip_colliding() and get_parent().shoot_timer.is_stopped():
		var direction = (get_global_mouse_position() - global_position).normalized()
		var new_bullet = AdvancedBullet.instantiate()
		new_bullet.prepare(direction)
		new_bullet.global_position = $Laser.global_position
		get_tree().get_root().add_child(new_bullet)
		get_parent().gun_sound_player.play()
		get_parent().shoot_timer.start()

func recoil(direction):
	self.position = self.position - direction * 10
