extends CanvasLayer

@onready var mouse: Control = %Mouse
@onready var _log : LogStream = LogStream.new("InputManager", Global.input_manager_log_level)

enum ControlMode { INIT, MKB, CONTROLLER, TOUCH }
var current_control_mode : ControlMode = ControlMode.INIT
const JOYPAD_DEADZONE: float = 0.28
var joypad_axis_value: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	DebugMenu.visibility_changed.connect(_on_debug_menu_visibility_changed)

func _on_debug_menu_visibility_changed() -> void:
	if mouse.is_active:
		if DebugMenu.visible:
			mouse.cursor_debug_container.show()
		else:
			mouse.cursor_debug_container.hide()
	elif DebugMenu.visible:
		mouse.cursor_debug_container.hide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		mouse.is_active = true
		change_control_mode(ControlMode.MKB)
	if event is InputEventKey:
		change_control_mode(ControlMode.MKB)
	if event is InputEventJoypadMotion:
		if abs(event.axis_value) > JOYPAD_DEADZONE:
			if event.is_action("action_move_left", true) or event.is_action("action_move_right", true) or event.is_action("action_move_up", true) or event.is_action("action_move_down", true):
				change_control_mode(ControlMode.CONTROLLER)
	if event is InputEventJoypadButton:
		change_control_mode(ControlMode.CONTROLLER)
	if event is InputEventScreenTouch:
		change_control_mode(ControlMode.TOUCH)

func change_control_mode(target_control_mode: ControlMode) -> void:
	if target_control_mode != current_control_mode:
		current_control_mode = target_control_mode
		match current_control_mode:
			ControlMode.MKB:
				_log.dbg("ControlMode changed to ControlMode.MKB")
				mouse.is_active = true
			ControlMode.CONTROLLER:
				_log.dbg("ControlMode changed to ControlMode.CONTROLLER")
				mouse.is_active = false
			ControlMode.TOUCH:
				_log.dbg("ControlMode changed to ControlMode.TOUCH")
				mouse.is_active = false
