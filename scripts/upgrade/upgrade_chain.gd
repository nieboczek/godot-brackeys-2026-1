class_name UpgradeChain
extends RefCounted

var id: String
var upgrades: Array[UpgradeResource]
var owned_upgrades: Array[UpgradeResource] = []


static func create(id_str: String, upgrades_arr: Array[UpgradeResource]) -> UpgradeChain:
	var chain := new()
	chain.id = id_str
	chain.upgrades = upgrades_arr
	return chain
