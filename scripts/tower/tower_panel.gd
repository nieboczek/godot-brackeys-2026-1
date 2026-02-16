class_name TowerPanel
extends PanelContainer

signal bought(scene: PackedScene)

@export var tower_texture: Texture2D
@export var tower_scene: PackedScene
@export var cost: int

@onready var button: TextureButton = $VBoxContainer/TextureButton

func _ready() -> void:
	$VBoxContainer/RichTextLabel.text = "[img width=20]res://assets/blood.png[/img]%s" % cost
	button.texture_normal = tower_texture
	button.disabled = cost > Manager.blood
	Manager.blood_changed.connect(_blood_changed)


func _blood_changed(new_blood: int) -> void:
	button.disabled = cost > new_blood

func _on_texture_button_pressed() -> void:
	Manager.blood -= cost
	bought.emit(tower_scene)
