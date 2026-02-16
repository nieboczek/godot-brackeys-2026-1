extends Node

const ENEMY_MAP: Dictionary[String, EnemyResource] = {
	"sheep": preload("res://resources/enemy/sheep.tres"),
	"cow": preload("res://resources/enemy/cow.tres"),
	"pig": preload("res://resources/enemy/pig.tres"),
	"chicken": preload("res://resources/enemy/chicken.tres"),
	"duck": preload("res://resources/enemy/duck.tres"),
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

signal health_changed(new_health: int)
signal blood_changed(new_blood: int)
signal new_round(n: int)

var current_round: Array[SpawnInfo]
var round_num: int = 0
var round_timer: float = 0.0
var health: int = 50:
	set(value):
		health = value
		health_changed.emit(value)
var blood: int = 50:
	set(value):
		blood = value
		blood_changed.emit(value)


func _ready() -> void:
	Console.register_command(Command.of("start_round").executes(start_round))
	Console.register_command(Command.of("health").args(["new health: int"]).executes(_health_cmd))
	Console.register_command(Command.of("blood").args(["new blood: int"]).executes(_blood_cmd))


func _health_cmd(new_health: int) -> void:
	health = new_health

func _blood_cmd(new_blood: int) -> void:
	blood = new_blood


func damage(dmg: int) -> void:
	health -= dmg


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

		var instance := preload("res://scenes/enemy.tscn").instantiate()
		instance.res = ENEMY_MAP[enemy.enemy]
		
		Game.instance.path.add_child(instance)


class SpawnInfo:
	var enemy: String
	var time: float
	
	static func of(string: String) -> SpawnInfo:
		var info := new()
		var split := string.split(" ")
		info.enemy = split[1].strip_edges()
		info.time = float(split[0].strip_edges())
		return info
