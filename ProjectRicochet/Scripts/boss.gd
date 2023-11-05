extends LevelInit

const BATS_TOTAL_HEALTH = 1600
const BOSS_TOTAL_HEALTH = 2000
const FADE_DELTA = 1.75
var show_boss_bar = false
@onready var boss_bar = $CanvasLayer/BossBar
@onready var boss_health_bar = $CanvasLayer/BossBar/HealthBar
@onready var blackscreen = 		$CanvasLayer/BlackScreen
var boss_health = 0.0
var total_health = 1.0

var end_flag = false

var is_bats = false
var current_music = null
var should_play_music = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	boss_bar.modulate.a = 0.0
	blackscreen.modulate.a = 0.0
	player.change_camera_zoom(4, 2)
	Global.boss_level_flag = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not $Sounds/WindSound.is_playing():
		$Sounds/WindSound.play()
	if should_play_music and not current_music.is_playing():
		current_music.play()
	#else:
	#	if current_music != null:
	#		current_music.stop()
	if end_flag:
		$Music/BossMusic.volume_db -= 1
		Engine.time_scale = 0.2
		blackscreen.modulate.a = lerp(blackscreen.modulate.a, 1.0, delta*FADE_DELTA)
		boss_bar.modulate.a = lerp(boss_bar.modulate.a, 0.0, delta)
		if blackscreen.modulate.a >= 0.9:
			cleanup()
			SceneSwitcher.switch_scene(SceneSwitcher.Scenes.END)
	else:
		if show_boss_bar:
			boss_bar.modulate.a = lerp(boss_bar.modulate.a, 1.0, delta)
			var bar_scale = 1
			if is_bats:
				bar_scale = boss_health / BATS_TOTAL_HEALTH
			else:
				$CanvasLayer/BossBar/BatsLabel.visible = false
				$CanvasLayer/BossBar/BossLabel.visible = true
				bar_scale = boss_health / BOSS_TOTAL_HEALTH
			if bar_scale >= 0:
				boss_health_bar.scale.x = bar_scale
			else:
				boss_health_bar.scale.x
		else:
			boss_bar.modulate.a = lerp(boss_bar.modulate.a, 0.0, delta)

func engage_boss():
	total_health = boss_health
	show_boss_bar = true
	if is_bats:
		current_music = $Music/BatMusic
	else:
		current_music = $Music/BossMusic
	should_play_music = true


func cleanup():
	for child in get_children():
		child.queue_free()


func _on_bats_spawner_activated():
	is_bats = true


func _on_bats_spawner_completed():
	#end_flag = true
	var second_tilemap : TileMap = $TileMap2
	second_tilemap.set_layer_enabled(0, true)
	show_boss_bar = false
	$FallArea/Shape1.disabled = true
	is_bats = false
	should_play_music = false

func _on_end_timer_timeout():
	var node_children = get_tree().get_root().get_children()
	goto_end(node_children)


func _on_boss_spawner_completed():
	end_flag = true


func _on_fall_area_body_entered(body):
	if body.is_in_group("player"):
		body.destroy()
		show_boss_bar = false


