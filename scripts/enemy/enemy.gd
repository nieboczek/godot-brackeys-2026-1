class_name Enemy
extends PathFollow2D

@export var speed: float = 40.0
@export var health: int = 10
@export var damage: int = 1
@export var center_offset: Vector2


func _process(delta: float) -> void:
	progress += speed * delta
	if progress_ratio > 0.99:
		Manager.damage(damage)
		queue_free()


func add_damage(dmg: int) -> void:
	health -= dmg
	if health <= 0:
		queue_free()

func will_kill(dmg: int) -> bool:
	return dmg > health
