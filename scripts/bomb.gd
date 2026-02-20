class_name Bomb
extends Arrow

var blast_radius: float = 50.0
var triggered: bool = false

func _ready() -> void:
	scale = Vector2(1.5, 1.5)

func _draw() -> void:
	if triggered:
		draw_circle(Vector2.ZERO, blast_radius, Color(1, 0, 0, 0.1))

func _after_hit() -> void:
	if triggered:
		return

	triggered = true
	target = null
	
	var a: Area2D = Area2D.new()
	a.collision_mask = 1
	a.body_entered.connect(_body_entered)
	a.body_exited.connect(_body_exited)
	
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = blast_radius
	shape.shape = circle
	
	a.add_child(shape)
	add_child(a)
	queue_redraw()
	
	await get_tree().create_timer(2.0).timeout
	
	for body in bodies:
		hit_target.emit(body)
	queue_free()


var bodies: Array[Enemy]

func _body_entered(body: Node2D) -> void:
	bodies.append(body.get_parent())


func _body_exited(body: Node2D) -> void:
	bodies.erase(body.get_parent())
