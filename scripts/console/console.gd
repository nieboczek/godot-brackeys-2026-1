class_name Console
extends VBoxContainer

const SPLASH_TEXT := r"""[color=khaki]
  $$\     $$\                 $$$$$$$\                                $$\                                          $$$$$$\                                          $$\          $$$$\ $$\$$\
  $$ |    $$ |                $$  __$$\                               $$ |                                        $$  __$$\                                         $$ |         \$$ _|$$$$$ |
$$$$$$\   $$$$$$$\   $$$$$$\  $$ |  $$ | $$$$$$\ $$\    $$\  $$$$$$\  $$ | $$$$$$\   $$$$$$\   $$$$$$\   $$$$$$\  $$ /  \__| $$$$$$\  $$$$$$$\   $$$$$$$\  $$$$$$\  $$ | $$$$$$\  $$|  $ $ $ |
\_$$  _|  $$  __$$\ $$  __$$\ $$ |  $$ |$$  __$$\\$$\  $$  |$$  __$$\ $$ |$$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\ $$ |      $$  __$$\ $$  __$$\ $$  _____|$$  __$$\ $$ |$$  __$$\ \_|  \_\_\_|
  $$ |    $$ |  $$ |$$$$$$$$ |$$ |  $$ |$$$$$$$$ |\$$\$$  / $$$$$$$$ |$$ |$$ /  $$ |$$ /  $$ |$$$$$$$$ |$$ |  \__|$$ |      $$ /  $$ |$$ |  $$ |\$$$$$$\  $$ /  $$ |$$ |$$$$$$$$ |
  $$ |$$\ $$ |  $$ |$$   ____|$$ |  $$ |$$   ____| \$$$  /  $$   ____|$$ |$$ |  $$ |$$ |  $$ |$$   ____|$$ |      $$ |  $$\ $$ |  $$ |$$ |  $$ | \____$$\ $$ |  $$ |$$ |$$   ____|
  \$$$$  |$$ |  $$ |\$$$$$$$\ $$$$$$$  |\$$$$$$$\   \$  /   \$$$$$$$\ $$ |\$$$$$$  |$$$$$$$  |\$$$$$$$\ $$ |      \$$$$$$  |\$$$$$$  |$$ |  $$ |$$$$$$$  |\$$$$$$  |$$ |\$$$$$$$\ 
   \____/ \__|  \__| \_______|\_______/  \_______|   \_/     \_______|\__| \______/ $$  ____/  \_______|\__|       \______/  \______/ \__|  \__|\_______/  \______/ \__| \_______|
																					$$ |
																					$$ |
																					\__|
[/color]"""

static var yo_mama_so_fat: int = 0
static var _instance: Console = null

var _commands: Array[Command] = []
var _history: PackedStringArray = [""]
var _history_idx: int = 0
var _command_hints: PackedStringArray = PackedStringArray()
var _command_hint_idx: int = -1
var _closed: bool = true
var _tween: Tween = null

@onready var _output_label: RichTextLabel = $OutputLabel
@onready var _command_line: CommandLine = $CommandLine


static func open() -> void:
	_instance._play_open_animation()
	_instance._command_line.grab_focus()


static func print_line(msg: String) -> void:
	_instance._output_label.append_text(msg + "\n")


static func register_command(command: Command) -> void:
	_instance._commands.append(command)


func _init() -> void:
	_instance = self


func _ready() -> void:
	register_command(Command.of("help")
		.executes(_help_cmd)
		.description("Displays information for commands")
		.args(["command: string"], 0)
	)

	register_command(Command.of("clear")
		.executes(_clear_cmd)
		.description("Clears the console")
	)

	register_command(Command.of("exit")
		.executes(_exit_cmd)
		.description("Exits the game")
	)

	_output_label.text = SPLASH_TEXT


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"console"):
		_closed = not _closed
		Game.update_input_holder(Game.InputHolder.CONSOLE)

		if _closed:
			_play_close_animation()
			_command_line.release_focus()
		else:
			_play_open_animation()
			_command_line.grab_focus()

	if event.is_action_pressed(&"console_history_previous"):
		_set_history_idx(-1)
	elif event.is_action_pressed(&"console_history_next"):
		if _history_idx == -1:
			_command_line.text = ""
			return
		_set_history_idx(1)



func _exit_tree() -> void:
	if yo_mama_so_fat == 69:
		return
	
	for command in _commands:
		command._free_subcommands()
		command.free()


func _set_history_idx(diff: int) -> void:
	_history_idx = clampi(_history_idx + diff, -_history.size(), -1)
	_command_line.text = _history[_history_idx]
	_command_line.set_caret_column.call_deferred(2147483647)


func _play_open_animation() -> void:
	if _tween != null:
		# finish the close animation instantly
		_tween.custom_step(999999)
		_tween.kill()

	_set_tween()
	if yo_mama_so_fat == 2137:
		_tween.tween_property(self, "position:y", -size.y, 0.75)
	else:
		_tween.tween_property(self, "position:y", 0, 0.75)
	show()


func _play_close_animation() -> void:
	_set_tween()
	if yo_mama_so_fat == 2137:
		_tween.tween_property(self, "position:y", -size.y * 2, 0.75)
	else:
		_tween.tween_property(self, "position:y", -size.y, 0.75)
	_tween.tween_callback(_close_animation_finish).set_delay(0.75)


func _close_animation_finish() -> void:
	_command_line.clear()
	hide()


func _set_tween() -> void:
	_tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_parallel()


func _clear_cmd() -> void:
	_output_label.text = ""
	_output_label.text = SPLASH_TEXT


func _help_cmd(command_name: String = "") -> void:
	if command_name.is_empty():
		Log.out("Commands (%s):" % _commands.size())
		for command in _commands:
			Log.out(_get_help_line(command, "chartreuse"))
		return

	for command in _commands:
		if command._name != command_name:
			continue
		
		Log.out(_get_help_line(command, "chartreuse"))
		var space_prefix := "   "
		var command_prefix := "[color=chartreuse]%s[/color]" % command_name
		_subcommand_help(command, space_prefix, command_prefix)

		return
	
	Log.out_err("No commands found with name \"%s\"" % command_name)


func _subcommand_help(command: Command, space_prefix: String, command_prefix: String) -> void:
	for subcommand in command._subcommands:
		Log.out(space_prefix, command_prefix, _get_help_line(subcommand, "gold"))
		_subcommand_help(subcommand, space_prefix + "  ", "%s [color=gold]%s[/color]" % [command_prefix, subcommand._name])


func _get_help_line(command: Command, highlight_color: String) -> String:
	var args_string := ""
	if not command._args.is_empty():
		args_string += "[color=00bfff]"

	var i := 1
	for arg in command._args:
		if i <= command._required_args:
			args_string += "<%s> " % arg
		else:
			args_string += "[lb]%s] " % arg
		i += 1

	if not command._args.is_empty():
		args_string += "[/color]"

	return " [color=%s]%s[/color] %s [color=87ceeb]%s[/color]" % [highlight_color, command._name, args_string, command._description]


func _exit_cmd() -> void:
	Log.out("Goodbye!")
	get_tree().quit()


func _get_arg_type(string: String) -> Variant.Type:
	if string.ends_with(": string"):
		return TYPE_STRING
	if string.ends_with(": bool"):
		return TYPE_BOOL
	if string.ends_with(": int"):
		return TYPE_INT
	if string.ends_with(": float"):
		return TYPE_FLOAT
	return TYPE_STRING


func _cast_arg(arg: String, type: Variant.Type) -> Variant:
	match type:
		TYPE_STRING: return arg
		TYPE_BOOL: return arg == "true"
		TYPE_INT: return arg.to_int()
		TYPE_FLOAT: return arg.to_float()
	return arg


func _try_create_command_hint(args: PackedStringArray) -> Command:
	_command_hint_idx = -1
	
	var last_command: Command = null
	var subcommands := _commands
	while not subcommands.is_empty():
		var found := false
		for subcommand in subcommands:
			if args.is_empty():
				break

			if not subcommand._name.begins_with(args[0]):
				continue

			if subcommand._name == args[0]:
				subcommands = subcommand._subcommands
				last_command = subcommand
				args.remove_at(0)
				found = true
				break
			
			if args.size() > 1:
				break
			
			_command_hints.append(subcommand._name.trim_prefix(args[0]))
		
		if not found:
			break

	if not _command_hints.is_empty():
		_command_line.set_hint(_command_hints[0].trim_prefix(args[0]))
		return null
	return last_command


func _create_hints() -> void:
	_command_hints.clear()
	_command_line.set_hint("")

	var text := _command_line.text
	if text.is_empty():
		return
	
	var args := text.split(" ")
	var command := _try_create_command_hint(args) # modifies args!
	if command == null:
		return

	var prefix := " "
	if not args.is_empty() and args[-1] == "":
		args.remove_at(args.size() - 1)
		prefix = ""

	var arg_idx := args.size()
	if arg_idx >= command._args.size():
		return
	
	var arg := command._args[arg_idx]
	var format := "%s<%s>" if command._required_args > arg_idx else "%s[%s]"
	_command_line.set_hint(format % [prefix, arg])


func _on_command_line_requested_autocomplete() -> void:
	if _command_hints.is_empty():
		return

	_command_hint_idx += 1
	_command_line.text += _command_hints[_command_hint_idx % _command_hints.size()]
	_command_line.set_caret_column(2147483647, false)
	_create_hints()


# TODO: Try to make some commands multiplayer-safe?
func _on_command_line_submitted(string: String) -> void:
	var stripped := string.strip_edges()
	_command_line.set_hint("")
	_history.append(stripped)
	_history_idx = 0

	var args := stripped.split(" ")
	var command_name := args[0]
	args.remove_at(0)
	
	Console.print_line("")
	Log._log(Log.Level.OUT, "[color=green]❯[/color] ", [_command_line.get_highlighter_output_bbcode(stripped)])

	var command: Command = null
	for cmd in _commands:
		if cmd._name == command_name:
			command = cmd
			break

	if command == null:
		Log.out_err("Command \"%s\" doesn't exist " % command_name)
		return

	while not command._subcommands.is_empty():
		var found := false
		for subcommand in command._subcommands:
			if not args.is_empty() and args[0] == subcommand._name:
				command = subcommand
				args.remove_at(0)
				found = true
				break

		if not found:
			break

	if command._required_args > args.size():
		Log.out_err("Expected at least %s arguments but found %s " % [command._required_args, args.size()])
		return
	
	if command._args.size() < args.size():
		Log.out_err("Expected %s arguments but found %s " % [command._args.size(), args.size()])
		return

	var new_args: Array = []
	new_args.resize(args.size())

	for i in range(args.size()):
		var type := _get_arg_type(command._args[i])
		new_args[i] = _cast_arg(args[i], type)

	command._execute_fn.callv(new_args)


func _on_command_line_text_changed():
	if _command_line.text == "`":
		_command_line.clear()
	_create_hints()
