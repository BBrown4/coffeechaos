extends Resource
class_name Upgrade

@export_category("Upgrade Info")
@export var upgrade_name: String
@export_multiline var upgrade_description: String

@export_category("Upgrade Effect")
enum EffectType {
	STAT_MODIFIER,
	FLAG_UNLOCK,
	SPECIAL
}

@export var effect_type: EffectType = EffectType.STAT_MODIFIER

@export var target_stat: String = "" # e.g. "fire_rate", "max_health", "move_speed"
@export var value: float = 0.0

@export var flag_name: String = "" # e.g. "has_pierce", "has_explosive" etc.
@export var increments_flag: bool = false
@export var flag_value_name: String = ""
@export var flag_value: float = 0.0

@export var custom_script: Script # optional custom script to run special logic (advanced use)
