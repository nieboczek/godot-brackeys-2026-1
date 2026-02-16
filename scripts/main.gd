class_name Main extends Node

func _ready() -> void:
	var args := OS.get_cmdline_args()
	
	for arg in args:
		if arg == "--load-now":
			_load_game()


func _load_game() -> void:
	var game := preload("res://scenes/game.tscn").instantiate()
	get_tree().root.add_child.call_deferred(game)
	$Menu.queue_free()


func _on_menu_start_game() -> void:
	_load_game()
