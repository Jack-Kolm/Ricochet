extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func unlock():
	$LockedSprite.visible = false
	$UnlockedSprite.visible = true
	$UnlockTimer.start()
	$UnlockSound.play()



func _on_explosion_sprite_animation_finished():
	queue_free()


func _on_unlock_timer_timeout():
	$CollisionShape2D.disabled = true
	$UnlockedSprite.visible = false
	$ExplosionSprite.visible = true
	$ExplosionSprite.play()
	$ExplosionSound.play()
