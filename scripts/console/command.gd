class_name Command
extends Object

var _name: String
var _description: String
var _subcommands: Array[Command] = []
var _args: PackedStringArray = PackedStringArray()
var _required_args: int = 0
var _execute_fn: Callable


static func of(name: String) -> Command:
	var command := new()
	command._name = name
	return command


func executes(function: Callable) -> Command:
	_execute_fn = function
	return self


func description(desc: String) -> Command:
	_description = desc
	return self


func subcommand(command: Command) -> Command:
	_subcommands.append(command)
	return self


## If [param required_args_count] is [code]-1[/code], the actual required _args
## will be set to the number of elements in [param args_array].
func args(args_array: PackedStringArray, required_args_count: int = -1) -> Command:
	_args = args_array
	if required_args_count == -1:
		_required_args = _args.size()
	else:
		_required_args = required_args_count
	
	return self


func _free_subcommands() -> void:
	for command in _subcommands:
		command._free_subcommands()
		command.free()
