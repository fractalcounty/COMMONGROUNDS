@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("DebugMenu", "res://addons/debug_menu/debug_menu.tscn")

	# FIXME: This appears to do nothing.
#	if not Projectconfig.has_setting("application/config/version"):
#		Projectconfig.set_setting("application/config/version", "1.0.0")
#
#	Projectconfig.set_initial_value("application/config/version", "1.0.0")
#	Projectconfig.add_property_info({
#		name = "application/config/version",
#		type = TYPE_STRING,
#	})
#
#	if not InputMap.has_action("cycle_debug_menu"):
#		InputMap.add_action("cycle_debug_menu")
#		var event := InputEventKey.new()
#		event.keycode = KEY_F3
#		InputMap.action_add_event("cycle_debug_menu", event)
#
#	Projectconfig.save()


func _exit_tree() -> void:
	remove_autoload_singleton("DebugMenu")
	# Don't remove the project setting's value and input map action,
	# as the plugin may be re-enabled in the future.
