class_name Tower
extends Node2D

@export var cooldown: float = 0.0
@export var damage: int = 1
@export var tower_range: float = 80.0
@export var arrow_speed: float = 160.0
@export_group("cosmetic stuff")
@export var detector_offset: Vector2
@export var shoot_start: Vector2
@export var arrow_texture: Texture2D
@export var arrow_max_height: float = 60.0

var enemies_to_shoot: Array[Enemy] = []
var current_cooldown := 0.0

func _ready() -> void:
	$EnemyDetector/CollisionShape.shape.radius = tower_range


func enable() -> void:
	$EnemyDetector.monitoring = true


func _on_enemy_detector_body_entered(body: Node2D) -> void:
	enemies_to_shoot.append(body.get_parent())


func _on_enemy_detector_body_exited(body: Node2D) -> void:
	enemies_to_shoot.erase(body.get_parent())


func _process(delta: float) -> void:
	current_cooldown -= delta
	if enemies_to_shoot.is_empty():
		return

	if current_cooldown <= 0.0:
		spawn_arrow()
		current_cooldown = cooldown


func spawn_arrow() -> void:
	var target: Enemy = null
	for enemy in enemies_to_shoot:
		var predicted := Manager.predicted_health[enemy]
		if predicted <= 0:
			continue
		
		if target == null or target.progress < enemy.progress:
			target = enemy

	if target == null:
		return

	Manager.predicted_health[target] -= damage
	
	var arrow := Arrow.new()
	arrow.texture = arrow_texture
	arrow.start = global_position + shoot_start
	arrow.position = arrow.start
	arrow.end = target.global_position + target.res.center_offset
	arrow.control = (arrow.start + arrow.end) / 2 - Vector2(0, arrow_max_height)
	arrow.duration = (arrow.start - arrow.end).length() / arrow_speed
	arrow.target = target
	arrow.hit_target.connect(_hit_target)
	
	add_child(arrow)


func _hit_target(body: Node2D) -> void:
	body.add_damage(damage)
