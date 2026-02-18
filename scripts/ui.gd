extends Control

@onready var tower_options: PanelContainer = $TowerOptions
@onready var tower_upgrades: VBoxContainer = $TowerOptions/Upgrades
@onready var hp_label: RichTextLabel = $HPLabel
@onready var round_label: Label = $RoundLabel
@onready var raycast: RayCast2D = $Raycast

var selected_tower: Tower
var placing_tower: Tower
var bodies_overlapping: int = 0

func _ready() -> void:
	Manager.health_changed.connect(_health_changed)
	Manager.blood_changed.connect(_blood_changed)
	Manager.new_round.connect(_new_round)
	
	for panel in $Towers.get_children():
		panel.bought.connect(_bought)

func _draw() -> void:
	if placing_tower:
		draw_circle(placing_tower.position + placing_tower.detector_offset, placing_tower.tower_range, Color(1, 1, 1, 0.1))
	if selected_tower:
		draw_circle(selected_tower.position + selected_tower.detector_offset, selected_tower.tower_range, Color(1, 1, 1, 0.1))

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"place_tower"):
		return
		
	if placing_tower != null and bodies_overlapping == 0:
		var area: Area2D = placing_tower.get_node("OccupiedSpace")
		area.area_entered.disconnect(_area_entered)
		area.area_exited.disconnect(_area_exited)
		area.monitoring = false
		
		placing_tower.process_mode = Node.PROCESS_MODE_INHERIT
		placing_tower.modulate = Color.WHITE
		placing_tower.enable()
		placing_tower = null
		queue_redraw()
		Log.debug("Placed tower")
	elif raycast.is_colliding():
		selected_tower = raycast.get_collider().get_parent()
		clear_tower_options()
		populate_tower_options()
		queue_redraw()
	else:
		selected_tower = null
		clear_tower_options()
		queue_redraw()

func _process(_delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	raycast.position = mouse_pos
	
	if placing_tower == null:
		return

	var pos := mouse_pos
	placing_tower.position = pos
	queue_redraw()

func _bought(scene: PackedScene) -> void:
	var node := scene.instantiate()
	node.process_mode = Node.PROCESS_MODE_DISABLED
	Game.instance.towers.add_child(node)
	
	var area: Area2D = node.get_node("OccupiedSpace")
	area.area_entered.connect(_area_entered)
	area.area_exited.connect(_area_exited)
	
	assert(area.disable_mode == CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE)
	assert(area.collision_layer == 2)
	assert(area.collision_mask == 2)
	
	placing_tower = node
	placing_tower.modulate = Color(1, 1, 1, 0.7)

func clear_tower_options() -> void:
	tower_options.hide()
	for child in tower_upgrades.get_children():
		tower_upgrades.remove_child(child)

func populate_tower_options() -> void:
	tower_options.show()
	for chain in selected_tower.chains:
		var interface: TowerUpgrade = preload("res://scenes/tower_upgrade.tscn").instantiate()

		interface.set_chain.call_deferred(chain)
		interface.bought.connect(_bought_upgrade)
		tower_upgrades.add_child(interface)

func _bought_upgrade(chain: UpgradeChain, upgrade: UpgradeResource) -> void:
	selected_tower.add_upgrade(chain, upgrade)

func _area_entered(_body: Area2D) -> void:
	bodies_overlapping += 1
	placing_tower.modulate = Color(1, 0, 0, 0.7)

func _area_exited(_body: Area2D) -> void:
	bodies_overlapping -= 1
	if bodies_overlapping == 0:
		placing_tower.modulate = Color(1, 1, 1, 0.7)

func _blood_changed(new_blood: int) -> void:
	_set_label(Manager.health, new_blood)

func _health_changed(new_health: int) -> void:
	_set_label(new_health, Manager.blood)

func _set_label(health: int, blood: int) -> void:
	hp_label.text = "[img height=22]res://assets/heart.png[/img] %s   [img height=22]res://assets/blood.png[/img]%s" % [health, blood]

func _new_round(n: int) -> void:
	round_label.text = str(n)

func _on_round_button_pressed() -> void:
	if Manager.round_stopped:
		Manager.start_round()
