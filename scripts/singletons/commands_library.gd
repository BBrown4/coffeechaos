extends Node


func _ready() -> void:
	DevConsole.register_command(["godmode", "gm"], cmd_set_god_mode)
	DevConsole.register_command(["aimbot", "ab"], cmd_set_aimbot)
	DevConsole.register_command(["timescale", "ts", "speed"], cmd_set_time_scale)
	DevConsole.register_command(["freeze", "fz"], cmd_freeze_time)
	DevConsole.register_command(["unfreeze", "ufz"], cmd_unfreeze_time)
	
	DevConsole.console_log("Commands registered")


func cmd_set_god_mode(args: PackedStringArray) -> String:
	DevUtilities.god_mode = int(args[0])
	return "godmode %s" % DevUtilities.god_mode


func cmd_set_aimbot(args: PackedStringArray) -> String:
	DevUtilities.aimbot = int(args[0])
	return "aimbot %s" % DevUtilities.aimbot


func cmd_freeze_time(args: PackedStringArray) -> String:
	var result = cmd_set_time_scale([str(0.0)])
	return result


func cmd_unfreeze_time(args: PackedStringArray) -> String:
	var result = cmd_set_time_scale([str(1.0)])
	return result


func cmd_set_time_scale(args: PackedStringArray) -> String:
	var value = parse_float_arg(args)
	if is_nan(value):
		return "Usage: timescale <number>"
	
	Engine.time_scale = value
	return "Time scale set: %f" % Engine.time_scale


func parse_float_arg(args: PackedStringArray, index: int = 0) -> float:
	if index >= args.size():
		push_error("Missing argument ar index %d" % index)
		return NAN
	
	var raw = args[index].strip_edges()
	if raw.is_valid_float():
		return raw.to_float()
	else:
		push_error("Invalid float: '%s'" % raw)
		return NAN
