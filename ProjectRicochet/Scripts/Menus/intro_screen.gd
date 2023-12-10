extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var bullet_dir = $AdvancedRicochetBullet.global_position.direction_to($WallNormal.global_position)
	$AdvancedRicochetBullet.prepare(bullet_dir)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_hit_area_body_entered(body):
	print(body)
	body.play_good_hit()
	body.destroy()
	$HitNode.visible = false
	$Fader.activate()


func _on_fader_finished():
	SceneSwitcher.switch_scene(SceneSwitcher.Scenes.MENU)

