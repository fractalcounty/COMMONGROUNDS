extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var current_device = InputHelper.guess_device_name()
	Log.info("[InputManager] Initial device:", current_device)

	InputHelper.device_changed.connect(_on_device_changed)

# Calls when an input is detected
#func _input(event: InputEvent) -> void:
	#if not event is InputEventMouse and event.is_pressed():
		#Log.info("[InputManager] Pressed input: " + str(event.as_text()) + " " + str(InputHelper.device) + " " + str(InputHelper.device_index))

# Called when the player uses a new input device
func _on_device_changed(device: String, device_index: int) -> void:
	Log.info("[InputManager] Device changed: " + device)