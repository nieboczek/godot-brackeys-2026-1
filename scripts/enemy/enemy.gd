class_name Enemy
extends PathFollow2D

var res: EnemyResource
var health: int


func _ready() -> void:
	var shape: CollisionShape2D = $CharacterBody/CollisionShape
	shape.position = res.hitbox_pos
	shape.shape = res.hitbox
	
	var sprite: Sprite2D = $CharacterBody/Sprite
	sprite.position = res.pos
	sprite.texture = res.texture
	sprite.flip_h = res.mirror_horizontal
	
	health = res.health
	
	var tween := sprite.create_tween()
	tween.set_loops(2147483647)
	tween.tween_property(sprite, "scale:x", 0.9, 1.0)
	tween.parallel().tween_property(sprite, "scale:y", 1.1, 1.0)
	tween.tween_property(sprite, "scale:x", 1.1, 1.0)
	tween.parallel().tween_property(sprite, "scale:y", 0.9, 1.0)


func _process(delta: float) -> void:
	progress += res.speed * delta
	if progress_ratio > 0.99:
		Manager.damage(res.damage)
		queue_free()


func add_damage(dmg: int) -> void:
	health -= dmg
	if health <= 0:
		set_process(false)
		Manager.blood += res.blood_value
		$CharacterBody/Sprite.hide()
		$GPUParticles.restart()
		await get_tree().create_timer(3.0).timeout
		queue_free()

func will_kill(dmg: int) -> bool:
	return dmg > health
