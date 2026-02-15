class_name Enemy
extends PathFollow2D

@export var speed := 40.0
@export var health: float = 10
@export var damage: float = 1
@export var center_offset: Vector2


func _process(delta: float) -> void:
	progress += speed * delta
	if progress_ratio > 0.99:
		Manager.damage(damage)
		queue_free()


func add_damage(dmg: float) -> void:
	health -= dmg
	if health <= 0:
		queue_free()

func will_kill(dmg: float) -> bool:
	return dmg > health
