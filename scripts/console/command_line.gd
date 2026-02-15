class_name CommandLine
extends TextEdit

signal requested_autocomplete()
signal submitted(string: String)

const COMMAND_COLOR := Color.CHARTREUSE
const SUBCOMMAND_COLOR := Color.GOLD
const ARG_COLOR := Color.LIGHT_GRAY
const FONT_SIZE := 8

var _font: Font
var _hint_str := ""


func _ready() -> void:
	syntax_highlighter = CommandSyntaxHighlighter.new()
	_font = get_theme_default_font()


func _draw() -> void:
	var offset_x := 2.0 + get_line_width(0)
	var offset_y := get_line_height() - _font.get_descent(FONT_SIZE) + 1.5
	draw_string(_font, Vector2(offset_x, offset_y), _hint_str, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, Color.DARK_GRAY)


func _input(event: InputEvent) -> void:
	if not has_focus():
		return
	
	if event is InputEventKey:
		var ev: InputEventKey = event
		if ev.keycode == KEY_ENTER:
			if ev.pressed:
				submitted.emit(text)
				text = ""
			get_viewport().set_input_as_handled()
		elif ev.is_action_pressed(&"console_autocomplete"):
			requested_autocomplete.emit()
			get_viewport().set_input_as_handled()


func set_hint(hint: String) -> void:
	_hint_str = hint
	queue_redraw()


func get_highlighter_output_bbcode(string: String) -> String:
	var temp_text := text
	text = string
	var highlighted := syntax_highlighter.get_line_syntax_highlighting(0)
	text = temp_text

	var first_processed := false
	var substr_start := 0
	var output := ""

	for column: int in highlighted:
		output += text.substr(substr_start, column - substr_start) + ("[/color]" if first_processed else "")
		substr_start = column

		var color: Color = highlighted[column].color
		output += "[color=%s]" % color.to_html(false)

		first_processed = true

	output += text.substr(substr_start)
	if first_processed:
		output += "[/color]"
	return output


class CommandSyntaxHighlighter extends SyntaxHighlighter:
	func _get_command(name: String, subcommands: Array = []) -> Command:
		var search_list := subcommands if not subcommands.is_empty() else Console._instance._commands
		for command in search_list:
			if command._name == name:
				return command
		return null


	func _get_line_syntax_highlighting(_line: int) -> Dictionary:
		var ret := {}
		var buf := ""
		var command: Command = null
		var space_loc := 0
		var i := 0
		var current_subcommands: Array = Console._instance._commands
		
		for ch in get_text_edit().text + " ":
			var is_space := ch == " "
			if is_space:
				var command_from_buf := _get_command(buf, current_subcommands)
				if (command == null or not current_subcommands.is_empty()) and command_from_buf != null:
					ret[space_loc] = { "color": COMMAND_COLOR if command == null else SUBCOMMAND_COLOR }
					command = command_from_buf
					if not command._subcommands.is_empty():
						current_subcommands = command._subcommands
					else:
						current_subcommands = []
				else:
					ret[space_loc] = { "color": ARG_COLOR }

				space_loc = i
				buf = ""

			if not is_space:
				buf += ch
			i += 1

		return ret
