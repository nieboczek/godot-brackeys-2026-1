class_name Player extends CharacterBody2D

const SPEED: float = 300

func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector(&"left", &"right", &"up", &"down")
	velocity = input_dir * SPEED
	move_and_slide()
