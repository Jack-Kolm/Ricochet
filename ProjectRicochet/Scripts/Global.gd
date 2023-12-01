
extends Node

const PLAYER_MAX_HEALTH : float = 1000.0

var delta_factor = 1
var current_level_name : String
var boss_level_flag = false
var second_boss_flag = false
var elevator_checkpoint = false
var player_health : float = PLAYER_MAX_HEALTH
var revive_flag = false

enum Checkpoints {ELEVATOR, BAT, FINAL}
