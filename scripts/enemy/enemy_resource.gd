class_name EnemyResource
extends Resource

@export var hitbox: Shape2D
@export var hitbox_pos: Vector2
@export var texture: Texture2D
@export var center_offset: Vector2
@export var pos: Vector2
@export var mirror_horizontal: bool
@export_category("stats")
@export var speed: float = 40.0
@export var health: int = 10
@export var damage: int = 1
@export var blood_value: int = 2
