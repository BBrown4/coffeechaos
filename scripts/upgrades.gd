extends Node

enum UpgradeType {
	FASTER_SHOOT,
	EXTRA_HEALTH,
	SPREAD_SHOT,
	DOUBLE_SHOT,
	DOUBLE_SCORE,
	BOUNCING_SHOTS
}

func get_upgrade_name(upgrade: int):
	match upgrade:
		UpgradeType.FASTER_SHOOT: return "Faster Shooting"
		UpgradeType.EXTRA_HEALTH: return "Extra Health"
		UpgradeType.SPREAD_SHOT: return "Spread Shot"
		UpgradeType.DOUBLE_SHOT: return "Double Shot"
		UpgradeType.DOUBLE_SCORE: return "Double Score"
		UpgradeType.BOUNCING_SHOTS: return "Bouncing Shots"
		_: return "Unknown"

func apply_upgrade(main: Node, upgrade: int):
	match upgrade:
		UpgradeType.FASTER_SHOOT:
			var player = main.get_node("Player")
			player.shoot_cooldown = max(0.05, player.shoot_cooldown - 0.05)
		UpgradeType.EXTRA_HEALTH:
			main.health += 1
		UpgradeType.SPREAD_SHOT:
			var player = main.get_node("Player")
			player.has_spread = true
		UpgradeType.DOUBLE_SHOT:
			var player = main.get_node("Player")
			player.has_doubleshot = true
		UpgradeType.DOUBLE_SCORE:
			main.double_score = true
		UpgradeType.BOUNCING_SHOTS:
			var player = main.get_node("Player")
			player.has_bounce = true
