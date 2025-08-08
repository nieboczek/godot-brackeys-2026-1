extends VBoxContainer

signal start_game()


func _on_play_button_pressed() -> void:
	start_game.emit()
