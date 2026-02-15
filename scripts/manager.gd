extends Node

const ENEMY_MAP: Dictionary[String, PackedScene] = {
	"sheep": preload("res://scenes/enemy/sheep.tscn"),
	"cow": preload("res://scenes/enemy/cow.tscn"),
	"pig": preload("res://scenes/enemy/pig.tscn"),
	"chicken": preload("res://scenes/enemy/chicken.tscn"),
	"duck": preload("res://scenes/enemy/duck.tscn"),
}

const ROUNDS: Array[Array] = [
	[
		"1: sheep",
		"4: duck",
		"7: chicken",
		"10: cow",
		"13: pig",
	],
	[
		"2: cow",
		"6: pig",
		"10: sheep",
		"14: sheep",
		"16: cow",
	],
	[
		"0.1: pig",
		"2: pig",
		"4.1: sheep",
		"6.1: pig",
		"10.1: pig",
		"11.1: cow",
		"14.1: pig",
	]
]

signal health_changed(new_health: float)
signal new_round(n: int)

var current_round: Array[SpawnInfo]
var round_num: int = 0
var round_timer: float = 0.0
var health: float = 50


func _ready() -> void:
	Console.register_command(Command.of("start_round").executes(start_round))


func damage(dmg: float) -> void:
	health -= dmg
	health_changed.emit(health)


func start_round() -> void:
	Log.main("Started round ", round_num)
	current_round = []
	for string in ROUNDS[round_num]:
		current_round.append(SpawnInfo.of(string))
	
	round_num += 1
	new_round.emit(round_num)


func _process(delta: float) -> void:
	round_timer += delta
	if !current_round.is_empty() and current_round[0].time <= round_timer:
		var enemy = current_round.pop_front()
		var spawned := ENEMY_MAP[enemy.enemy].instantiate()
		Game.instance.path.add_child(spawned)


class SpawnInfo:
	var enemy: String
	var time: float
	
	static func of(string: String) -> SpawnInfo:
		var info := new()
		var split := string.split(" ")
		info.enemy = split[1].strip_edges()
		info.time = float(split[0].strip_edges())
		return info
