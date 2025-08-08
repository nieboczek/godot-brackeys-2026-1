class_name Game extends Node2D

static var instance: Game
static var player: Player

static var _up_events: Array[InputEvent]
static var _left_events: Array[InputEvent]
static var _right_events: Array[InputEvent]
static var _down_events: Array[InputEvent]


static func set_player_input_handling(state: bool) -> void:
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
