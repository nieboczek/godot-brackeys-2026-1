class_name Arrow
extends Sprite2D

signal hit_target

var time := 0.0

var duration: float
var target: Enemy
var start: Vector2
var control: Vector2
var end: Vector2

func _process(delta: float) -> void:
	time += delta
	var t := clampf(time / duration, 0, 1)

	end = target.global_position + target.center_offset
	global_position = start.lerp(control, t).lerp(
		control.lerp(end, t), t
	)

	rotation = (end - global_position).angle()

	if t >= 1:
		if target:
			hit_target.emit(target)
		queue_free()
