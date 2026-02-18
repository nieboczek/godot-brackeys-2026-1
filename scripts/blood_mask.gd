class_name BloodMask
extends Sprite2D

@onready var map: Sprite2D = $Map
@onready var shape_cast: ShapeCast2D = $ShapeCast

func add_new_scale(added_scale: float) -> void:
	set_new_scale(scale.x + added_scale)

func reposition() -> void:
	map.global_scale = Vector2.ONE
	map.global_position = Vector2(320, 180)
	infect_foliage()

func set_new_scale(new_scale: float) -> void:
	scale = Vector2(new_scale, new_scale)
	map.global_scale = Vector2.ONE
	map.global_position = Vector2(320, 180)
	infect_foliage()

func infect_foliage() -> void:
	shape_cast.margin = scale.x * 2
	shape_cast.force_shapecast_update()
	for i in range(shape_cast.get_collision_count()):
		var collider := shape_cast.get_collider(i)
		var sprite: Sprite2D = collider.get_node("Sprite")
		
		var s: Texture2D
		match sprite.texture.resource_path.trim_prefix("res://assets/deco/"):
			"grass_1.png": s = preload("res://assets/deco/evil_grass_1.png")
			"grass_2.png": s = preload("res://assets/deco/evil_grass_2.png")
			"grass_3.png": s = preload("res://assets/deco/evil_grass_3.png")
			"rock_1.png": s = preload("res://assets/deco/evil_rock_1.png")
			"rock_2.png": s = preload("res://assets/deco/evil_rock_2.png")
			"evil_grass_1.png": return
			"evil_grass_2.png": return
			"evil_grass_3.png": return
			"evil_rock_1.png": return
			"evil_rock_2.png": return
			_:
				Log.err("Deco ", sprite.texture.resource_path, " has no mapping [BloodMask::infect_foliage]")
				return
		
		sprite.texture = s
