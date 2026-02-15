extends Control

@onready var hp_label: Label = $HPLabel
@onready var round_label: Label = $RoundLabel


func _ready() -> void:
	Manager.health_changed.connect(_health_changed)
	Manager.new_round.connect(_new_round)

func _health_changed(new_health: int) -> void:
	hp_label.text = "HP: %s" % new_health

func _new_round(n: int) -> void:
	round_label.text = str(n)
