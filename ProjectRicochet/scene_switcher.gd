extends Node
var init_main_scene = preload("res://Scenes/Levels/init_main.tscn")
var menu_scene = preload("res://Scenes/Menus/main_menu.tscn")
var boss_scene = preload("res://Scenes/boss.tscn")
var restart_scene = preload("res://Scenes/Menus/restart_menu.tscn")

enum Scenes {INITMAIN, MENU, RESTART, BOSS}

var current_scene = null
# Called when the node enters the scene tree for the first time.
func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count()-1)
	#switch_scene(Scenes.INITMAIN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func switch_scene(scene : Scenes):
	match scene:
		Scenes.INITMAIN:
			call_deferred("_deferred_switch_scene", init_main_scene)
		Scenes.RESTART:
			call_deferred("_deferred_switch_scene", restart_scene)

func _deferred_switch_scene(respath):
	if current_scene != null:
		current_scene.free()
	var new_scene = respath #load(respath)
	current_scene = new_scene.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene