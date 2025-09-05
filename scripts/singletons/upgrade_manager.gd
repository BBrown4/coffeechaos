extends Node

var available_upgrades: Array[Upgrade] = []

func _ready() -> void:
	_load_upgrades()

func _load_upgrades() -> void:
	var dir = DirAccess.open("res://upgrades/")
	if dir:
		for file_name in dir.get_files():
			if file_name.ends_with(".tres"):
				var upgrade = load("res://upgrades/" + file_name)
				if upgrade is Upgrade:
					available_upgrades.append(upgrade)

func get_random_choices(count: int = 3) -> Array[Upgrade]:
	var pool = available_upgrades.duplicate()
	pool.shuffle()
	return pool.slice(0, count)

func apply_upgrade(upgrade: Upgrade, player: Node) -> void:
	match upgrade.effect_type:
		Upgrade.EffectType.STAT_MODIFIER:
			if upgrade.target_stat in player:
				player.set(upgrade.target_stat, player.get(upgrade.target_stat) + upgrade.value)
		Upgrade.EffectType.FLAG_UNLOCK:
			if upgrade.flag_name in player:
				player.set(upgrade.flag_name, true)
				if upgrade.increments_flag:
					if upgrade.flag_value_name in player:
						player.set(upgrade.flag_value_name, player.get(upgrade.flag_value_name) + upgrade.flag_value)
		Upgrade.EffectType.SPECIAL:
			if upgrade.custom_script:
				var special = upgrade.custom_script.new()
				special.apply(player) # requires custom script to implement apply(player)
