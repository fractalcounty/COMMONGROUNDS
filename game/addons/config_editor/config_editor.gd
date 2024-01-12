@tool
extends EditorPlugin

# A class member to hold the dock during the plugin life cycle.
var config_editor_dock

func _enter_tree():
	# Initialization of the plugin goes here.
	# Load the dock scene and instantiate it.
	config_editor_dock = preload("res://addons/config_editor/ConfigEditor.tscn").instantiate()

	# Add the loaded scene to the docks.
	add_control_to_dock(DOCK_SLOT_LEFT_BR, config_editor_dock)
	# Note that LEFT_UL means the left of the editor, upper-left dock.


func _exit_tree():
	# Clean-up of the plugin goes here.
	# Remove the dock.
	remove_control_from_docks(config_editor_dock)
	# Erase the control from the memory.
	config_editor_dock.free()
