class_name Enemy
extends PathFollow2D

var res: EnemyResource
var health: int
var speed: float
var time_left_red: float = INF
var blood_effect_count: int = 0

@onready var sprite: Sprite2D = $CharacterBody/Anchor/Sprite


func add_blood_effects() -> void:
	blood_effect_count += 1
	if blood_effect_count == 1:
		sprite.texture = res.evil_texture
		speed += 10.0


func remove_blood_effects() -> void:
	blood_effect_count -= 1
	if blood_effect_count == 0:
		sprite.texture = res.texture
		speed -= 10.0


func _ready() -> void:
	var shape: CollisionShape2D = $CharacterBody/CollisionShape
	shape.position = res.hitbox_pos
	shape.shape = res.hitbox
	
	sprite.position = res.pos
	sprite.texture = res.texture
	sprite.flip_h = res.mirror_horizontal
	
	health = res.health
	speed = res.speed
	
	var anchor := $CharacterBody/Anchor
	var tween := anchor.create_tween()
	tween.set_loops(2147483647)
	tween.tween_property(anchor, "scale:x", 0.9, 1.0)
	tween.parallel().tween_property(anchor, "scale:y", 1.1, 1.0)
	tween.tween_property(anchor, "scale:x", 1.1, 1.0)
	tween.parallel().tween_property(anchor, "scale:y", 0.9, 1.0)


func _process(delta: float) -> void:
	time_left_red -= delta
	if time_left_red <= 0.0:
		modulate = Color.WHITE
	
	progress += speed * delta
	if progress_ratio > 0.99:
		Manager.damage(res.damage)
		queue_free()


func add_damage(dmg: int) -> void:
	if not is_processing():
		return
	
	health -= dmg
	
	if health <= 0:
		set_process(false)
		Manager.blood += res.blood_value
		modulate = Color.WHITE
		sprite.hide()
		$GPUParticles.restart()
		await get_tree().create_timer(3.0).timeout
		queue_free()
	else:
		modulate = Color(1, 0.2, 0.2)
		time_left_red = 0.5
