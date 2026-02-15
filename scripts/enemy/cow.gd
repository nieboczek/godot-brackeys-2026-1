extends Enemy

func _ready() -> void:
	var sprite := $CharacterBody/Sprite
	var tween := sprite.create_tween()
	tween.set_loops(2147483647)
	tween.tween_property(sprite, "scale:x", 0.9, 1.0)
	tween.parallel().tween_property(sprite, "scale:y", 1.1, 1.0)
	tween.tween_property(sprite, "scale:x", 1.1, 1.0)
	tween.parallel().tween_property(sprite, "scale:y", 0.9, 1.0)
