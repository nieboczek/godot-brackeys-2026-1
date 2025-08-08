extends Node

enum Level {
	FATAL,
	OUT,
	ERROR,
	MAIN,
	DEBUG
}

const MIN_LEVEL: Level = Level.DEBUG

var _inst_id_prefix := ""


## Initialize the logger with debug instance id (for multiple game instances testing).
func initialize(debug_inst_id: String) -> void:
	if not debug_inst_id.is_empty():
		_inst_id_prefix = "[color=darkgray]" + debug_inst_id + "[/color] "


## Get call stack with offset.
func get_call_stack(offset: int = 2) -> String:
	return "\n".join(get_stack().slice(offset).map(
		func(dict: Dictionary) -> String:
			return "  %s at %s:%s" % [dict["function"], dict["source"], dict["line"]]
	))


## Return a pretty "on" or "off" string
func boolean(bool_: bool) -> String:
	return "[color=green]on[/color]" if bool_ else "[color=lightcoral]off[/color]"


## Print an error message and open the console
func err(msg: String) -> void:
	_log(Level.ERROR, "[color=lightcoral]error[/color] ", msg)
	Console.open()


## Print an error message with the call stack, open the console and pause program execution in debug builds.
func fatal(msg: String) -> void:
	_log(Level.FATAL, "[color=darkred]fatal[/color] ", msg)

	var call_stack = get_call_stack()
	Console.print_line(call_stack)
	print(call_stack)

	Console.open()
	assert(false, "Fatal error raised.")


## Should be used for logs triggered by the console (Use [method out_err] for errors)
func out(msg: String) -> void:
	_log(Level.OUT, "[color=gray]❯[/color] ", msg)


## Should be used for errors triggered by the console
func out_err(msg: String) -> void:
	_log(Level.OUT, "[color=lightcoral]❯[/color] ", msg)


## Should be used for not so useful for the user info
func debug(msg: String) -> void:
	_log(Level.DEBUG, "[color=blueviolet]debug[/color] ", msg)


## Main log
func main(msg: String) -> void:
	_log(Level.MAIN, "[color=orange]main[/color] ", msg)


func _log(level: Level, prefix: String, msg: String) -> void:
	if level > MIN_LEVEL:
		return
	
	var string := _inst_id_prefix + prefix + msg
	Console.print_line(string)
	print_rich(string)
