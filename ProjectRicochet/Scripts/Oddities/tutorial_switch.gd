extends StaticBody2D

@export var start_visible = true


# Called when the node enters the scene tree for the first time.
func _ready():
	if start_visible:
		enable()
	else:
		disable()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func enable():
	$Hurtbox.monitoring = true
	self.visible = true

func disable():
	$Hurtbox.monitoring = false
	self.visible = false


func _on_hurtbox_body_entered(body):
	if body.is_in_group("ricochet_bullets"):
		if body.get_bounces() > 0:
			body.play_hit_sound()
			get_parent().good_hit()
		else:
			body.play_hit_sound(false)
			get_parent().bad_hit()
		body.destroy()
