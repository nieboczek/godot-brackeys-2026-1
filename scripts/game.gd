class_name Game extends Node2D

enum InputHolder {
	CONSOLE = 1,
	PAUSE = 2,
	MAIN_MENU = 4,
}

static var instance: Game
static var player: Player

static var _input_holders := InputHolder.MAIN_MENU as int
static var _up_events: Array[InputEvent]
static var _left_events: Array[InputEvent]
static var _right_events: Array[InputEvent]
static var _down_events: Array[InputEvent]


static func update_input_holder(input_holder: InputHolder, force_true: bool = false) -> void:
	var new_value := (_input_holders | input_holder) if force_true else (_input_holders ^ input_holder)
	if _input_holders > 0 and new_value == 0:
		_set_player_input_handling(true)
	elif _input_holders == 0 and new_value > 0:
		_set_player_input_handling(false)
	_input_holders = new_value


static func _set_player_input_handling(state: bool) -> void:
	# This is so stupid but at least we don't give up on _physics_process in Player
	if state:
		_set_events(&"up", _up_events)
		_set_events(&"left", _left_events)
		_set_events(&"right", _right_events)
		_set_events(&"down", _down_events)
	else:
		_up_events = _extract_events(&"up")
		_left_events = _extract_events(&"left")
		_right_events = _extract_events(&"right")
		_down_events = _extract_events(&"down")


static func _set_events(action: StringName, events: Array[InputEvent]) -> void:
	for event in events:
		InputMap.action_add_event(action, event)


static func _extract_events(action: StringName) -> Array[InputEvent]:
	var actions := InputMap.action_get_events(action)
	InputMap.action_erase_events(action)
	return actions


func _ready() -> void:
	instance = self
	player = $Player
	
	var console: Console = $/root/Main/Console
	console.yo_mama_so_fat = 69
	console.reparent(player.get_node(^"Camera"))
	console.yo_mama_so_fat = 2137
	console.size = Vector2(1920, 540)
	console.position = Vector2(-960, -1080)
	if not console._closed:
		console._closed = true
		console._play_close_animation()
