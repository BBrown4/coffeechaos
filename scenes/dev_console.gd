extends CanvasLayer


@onready var output: RichTextLabel = $Panel/RichTextLabel
@onready var input: LineEdit  = $Panel/LineEdit


var is_open: bool = false
var commands: Dictionary = {}
var history: Array[String] = []
var history_index = -1


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_console"):
		is_open = !is_open
		visible = is_open
		
		if is_open:
			input.clear()
			input.grab_focus()
		get_viewport().set_input_as_handled()
	
	if is_open and event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP:
				if history.size() > 0:
					if history_index == -1:
						history_index = history.size() - 1
					else:
						history_index = max(0, history_index - 1)
					input.text = history[history_index]
					input.caret_column = input.text.length()
					get_viewport().set_input_as_handled()
			KEY_DOWN:
				if history.size() > 0:
					if history_index == -1:
						return
					history_index = min(history.size(), history_index + 1)
					if history_index == history.size():
						input.clear()
						history_index = -1
					else:
						input.text = history[history_index]
						input.caret_column = input.text.length()
					get_viewport().set_input_as_handled()


func _on_line_edit_text_submitted(new_text: String) -> void:
	run_command(new_text)
	if not new_text.strip_edges().is_empty():
		history.append(new_text.strip_edges())
	history_index = -1
	input.clear()

func register_command(names, callback: Callable):
	if typeof(names) == TYPE_STRING:
		commands[names] = callback
	elif typeof(names) == TYPE_ARRAY:
		for name in names:
			commands[name] = callback


func run_command(command: String) -> void:
	var parts = command.strip_edges().split(" ", false)
	if parts.is_empty():
		return
	var cmd = parts[0]
	var args = parts.slice(1, parts.size())
	
	console_log("> " + command)
	
	if commands.has(cmd):
		var result = commands[cmd].call(args)
		if result != null:
			console_log(str(result))
	else:
		console_log("Unknown command: " + cmd)


func console_log(text: String) -> void:
	output.append_text(text + "\n")
	output.scroll_to_line(output.get_line_count() - 1)
