extends Control

@onready var hp_label: RichTextLabel = $HPLabel
@onready var round_label: Label = $RoundLabel

var placing_tower: Node2D
var bodies_overlapping: int = 0

func _ready() -> void:
	Manager.health_changed.connect(_health_changed)
	Manager.blood_changed.connect(_blood_changed)
	Manager.new_round.connect(_new_round)
	
	for panel in $Towers.get_children():
		panel.bought.connect(_bought)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"place_tower") and placing_tower != null and bodies_overlapping == 0:
		var area: Area2D = placing_tower.get_node("OccupiedSpace")
		area.area_entered.disconnect(_area_entered)
		area.area_exited.disconnect(_area_exited)
		area.monitoring = false
		
		placing_tower.enable()
		placing_tower = null
		Log.debug("Placed tower")

func _process(_delta: float) -> void:
	if placing_tower == null:
		return

	var pos := get_global_mouse_position()
	placing_tower.position = pos

func _bought(scene: PackedScene) -> void:
	var node := scene.instantiate()
	node.process_mode = Node.PROCESS_MODE_DISABLED
	Game.instance.towers.add_child(node)
	
	var area: Area2D = node.get_node("OccupiedSpace")
	area.area_entered.connect(_area_entered)
	area.area_exited.connect(_area_exited)
	
	assert(area.collision_layer == 2)
	assert(area.collision_mask == 2)
	
	placing_tower = node
	Log.debug("Started placing tower")

func _area_entered(_body: Area2D) -> void:
	bodies_overlapping += 1
	Log.debug("overlapping +1")

func _area_exited(_body: Area2D) -> void:
	bodies_overlapping -= 1
	Log.debug("overlapping -1")

func _blood_changed(new_blood: int) -> void:
	_set_label(Manager.health, new_blood)

func _health_changed(new_health: int) -> void:
	_set_label(new_health, Manager.blood)

func _set_label(health: int, blood: int) -> void:
	hp_label.text = "[img height=22]res://assets/heart.png[/img] %s   [img height=22]res://assets/blood.png[/img]%s" % [health, blood]

func _new_round(n: int) -> void:
	round_label.text = str(n)
