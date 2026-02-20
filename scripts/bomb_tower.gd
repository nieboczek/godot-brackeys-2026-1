extends Tower

func _init_chains() -> Array[UpgradeChain]:
	return [
		#UpgradeChain.create("sharper", [
			#preload("res://resources/upgrade/sharper_arrows.tres")
		#])
	]

func _create_arrow() -> Arrow:
	return Bomb.new()

func _predict_health(_enemy: Enemy) -> void:
	pass

func _hit_target(body: Enemy) -> void:
	body.add_damage(damage)
	Manager.predicted_health[body] -= damage
