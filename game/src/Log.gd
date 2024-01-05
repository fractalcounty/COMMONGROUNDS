extends Node
## Logging autoload for general debugging purposes
##
## Automatically determines the environment the game is
## running in and logs in an appropriate manner
##
## Example usage: 'Log.debug("Hello world!", node)'
## Result: '[Script.gd] Hello world!'

## Prefix concatenation function
func _prefix(caller: Node = null) -> String:
	const DEFAULT_PREFIX: String = "Debug"
	return "[%s]" % (caller.get_script().resource_path.get_file() if caller and caller.get_script() else DEFAULT_PREFIX)

## Main logging functions
func debug(message: String, caller: Node = null) -> void:
	var _message: String = _prefix(caller) + " " + message
	_log_to_console(_message, "log")

func warn(message: String, caller: Node = null) -> void:
	var _message: String = _prefix(caller) + " " + message
	_log_to_console(_message, "warn")
	push_warning(_message)

func error(message: String, caller: Node = null) -> void:
	var _message: String = _prefix(caller) + " " + message
	_log_to_console(_message, "error")
	push_error(_message)

## Helper function for final logging action
func _log_to_console(message: String, log_type: String) -> void:
	if System.is_web_debug_export:
		JavaScriptBridge.eval("console.%s('%s')" % [log_type, message])
	else:
		print(message)
