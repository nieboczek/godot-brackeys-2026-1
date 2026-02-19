class_name TowerUpgrade
extends MarginContainer

@onready var next_panel: PanelContainer = $Container/PanelContainer
@onready var next_label: Label = $Container/PanelContainer/MarginContainer/Next/Label
@onready var next_img: TextureRect = $Container/PanelContainer/MarginContainer/Next/TextureRect
@onready var next_cost: RichTextLabel = $Container/PanelContainer/MarginContainer/Next/RichTextLabel

@onready var current_label: Label = $Container/Current/Label
@onready var current_img: TextureRect = $Container/Current/TextureRect

var next_upgrade: UpgradeResource = null
var current_upgrade: UpgradeResource = null
var chain: UpgradeChain

signal bought(achain: UpgradeChain, upgrade: UpgradeResource)


const BUYABLE_UPGRADE := preload("res://resources/upgrade/style/buyable_upgrade.tres")
const INACTIVE_UPGRADE := preload("res://resources/upgrade/style/inactive_upgrade.tres")


func set_chain(achain: UpgradeChain) -> void:
	chain = achain

	var next_idx := chain.owned_upgrades.size()
	if next_idx > 0:
		set_current_upgrade(chain.owned_upgrades[next_idx - 1])
	if next_idx < chain.upgrades.size():
		set_next_upgrade(chain.upgrades[next_idx])

func _ready() -> void:
	Manager.blood_changed.connect(_blood_changed)
	_blood_changed(Manager.blood)

func _blood_changed(new_blood: int) -> void:
	if chain == null:
		await get_tree().process_frame
		await get_tree().process_frame # i honestly don't know why putting it twice works

	if next_upgrade == null or next_upgrade.cost > new_blood:
		next_panel.add_theme_stylebox_override("panel", INACTIVE_UPGRADE)
	else:
		next_panel.add_theme_stylebox_override("panel", BUYABLE_UPGRADE)

func set_next_upgrade(upgrade: UpgradeResource) -> void:
	next_upgrade = upgrade
	if upgrade == null:
		next_panel.add_theme_stylebox_override("panel", INACTIVE_UPGRADE)
		next_label.text = "Maximally upgraded"
		next_img.texture = preload("res://assets/upgrade/null.png")
		next_cost.text = ""
		return
	
	next_label.text = upgrade.name
	next_img.texture = upgrade.texture
	next_cost.text = "[img height=24]res://assets/blood.png[/img]%s" % upgrade.cost

func set_current_upgrade(upgrade: UpgradeResource) -> void:
	current_upgrade = upgrade
	current_label.text = upgrade.name
	current_img.texture = upgrade.texture


func buy() -> void:
	set_current_upgrade(next_upgrade)
	Manager.blood -= next_upgrade.cost
	bought.emit(chain, next_upgrade)
	
	var idx := chain.upgrades.find(next_upgrade) + 1
	if idx < chain.upgrades.size():
		set_next_upgrade(chain.upgrades[idx])
	else:
		set_next_upgrade(null)


func _on_upgrade_button_pressed() -> void:
	if next_upgrade != null and Manager.blood >= next_upgrade.cost:
		buy()
