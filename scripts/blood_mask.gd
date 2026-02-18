class_name BloodMask
extends Sprite2D

@onready var map: Sprite2D = $Map

func add_new_scale(added_scale: float) -> void:
	set_new_scale(scale.x + added_scale)

func reposition() -> void:
	map.global_scale = Vector2.ONE
	map.global_position = Vector2(320, 180)

func set_new_scale(new_scale: float) -> void:
	scale = Vector2(new_scale, new_scale)
	map.global_scale = Vector2.ONE
	map.global_position = Vector2(320, 180)
