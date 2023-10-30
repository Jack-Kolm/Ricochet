extends LevelInit

const TOTAL_BOSS_HEALTH = 1200
const FADE_DELTA = 1
var show_boss_bar = false
@onready var boss_bar = $CanvasLayer/BossBar
@onready var boss_health_bar = $CanvasLayer/BossBar/HealthBar
@onready var blackscreen = 		$CanvasLayer/BlackScreen
var boss_health = 0.0
var total_health = 1.0

var end_flag = false

# Called when the node enters the scene tree for the first time.
func _ready():
	boss_bar.modulate.a = 0.0
	blackscreen.modulate.a = 0.0
	player.change_camera_zoom(5, 2)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if end_flag:
		Engine.time_scale = 0.2
		blackscreen.modulate.a = lerp(blackscreen.modulate.a, 1.0, delta*FADE_DELTA)
		boss_bar.modulate.a = lerp(boss_bar.modulate.a, 0.0, delta)
	if show_boss_bar:
		boss_bar.modulate.a = lerp(boss_bar.modulate.a, 1.0, delta)
	boss_health_bar.scale.x = (boss_health / total_health)

func engage_boss():
	total_health = boss_health
	show_boss_bar = true


func _on_spawner_completed():
	end_flag = true

func _on_end_timer_timeout():
	var node_children = get_tree().get_root().get_children()
	goto_end(node_children)

