extends StaticBody2D

class_name Gun

const RECOIL_DELTA = 6
const RUN_DELTA = 10
const GUN_OFFSET_Y = -10.0
const GUN_RUN_OFFSET_X = 5
var angle_offset = PI/2

@onready var raycast = $GunRayCast
@onready var aimcast = $AimCast
@onready var tip_box = $GunTipBox

@onready var AdvancedBullet = preload("res://Scenes/Bullets/advanced_ricochet_bullet.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	#raycast.global_position = self.global_position;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var laser : Line2D = $LaserLine
	laser.set_point_position(0, $GunTipBox.position)

	if aimcast.is_colliding():
		if aimcast.get_collider().is_in_group("terrain"):
			var point = aimcast.get_collision_point()
			laser.set_point_position(1, to_local(point))
			$LaserLight.visible = true
			$LaserLight.global_position = point
	else:
		$LaserLight.visible = false
		laser.set_point_position(1, aimcast.target_position)


	if get_parent().player_sprite.animation == "run":
		self.position = lerp(self.position, Vector2(GUN_RUN_OFFSET_X*get_parent().direction, GUN_OFFSET_Y), delta*RUN_DELTA)
	else:
		self.position = lerp(self.position, Vector2(0, GUN_OFFSET_Y), delta*RECOIL_DELTA)
	
	look_at(get_global_mouse_position())
	self.rotation = self.rotation - angle_offset
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
	if $GunRayCast.is_tip_colliding() and $GunRayCast.get_collider().is_in_group("terrain"):
		return
	elif get_parent().shoot_timer.is_stopped():
		var direction = (get_global_mouse_position() - $GunTipBox.global_position)
		var new_bullet = AdvancedBullet.instantiate()
		new_bullet.prepare(direction)
		new_bullet.global_position = $GunTipBox.global_position
		get_tree().get_root().add_child(new_bullet)
		get_parent().gun_sound_player.play()
		get_parent().shoot_timer.start()

func recoil(direction):
	self.position = self.position - direction * 3
