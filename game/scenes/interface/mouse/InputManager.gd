extends CanvasLayer

@onready var mouse : Node2D = $Mouse
@onready var debug_container : VBoxContainer = $DebugContainer
@onready var debug_label_1 : Label = $DebugContainer/Label1
@onready var debug_label_2 : Label = $DebugContainer/Label2
@onready var debug_label_3 : Label = $DebugContainer/Label3
@onready var debug_offset : Vector2 = Vector2(0, 50)
@onready var _log : LogStream = LogStream.new("InputManager", Global.input_manager_log_level)
@onready var mouse_timer: Timer = $MouseTimer

enum ControlMode { INIT, MKB, CONTROLLER, TOUCH }
var current_control_mode : ControlMode = ControlMode.INIT
const DEADZONE: float = 0.28

var world : Node2D

var joypad_axis_value: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	mouse_timer.timeout.connect(_on_mouse_timer_timeout)
	debug_container.hide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		mouse_timer.start()
		show_mouse()
		change_control_mode(ControlMode.MKB)
	if event is InputEventKey:
		change_control_mode(ControlMode.MKB)
	if event is InputEventJoypadMotion:
		if abs(event.axis_value) > DEADZONE:
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
				show_mouse()
			ControlMode.CONTROLLER:
				_log.dbg("ControlMode changed to ControlMode.CONTROLLER")
				hide_mouse()
			ControlMode.TOUCH:
				_log.dbg("ControlMode changed to ControlMode.TOUCH")
				hide_mouse()
	
	if Input.is_action_just_pressed("action_debug"):
		debug_container.show()
	if Input.is_action_just_released("action_debug"):
		debug_container.hide()

func _on_mouse_timer_timeout() -> void:
	hide_mouse()
	
	#if event is InputEventMouseMotion:
		#debug_label_1.text = "viewport: " + str(event.position)

func _process(delta: float) -> void:
	if world != null:
		var world_pos : Vector2i = Vector2i(world.get_local_mouse_position())
		debug_label_2.text = "overworld: " + str(world_pos)
	
	var mouse_position : Vector2 = get_viewport().get_mouse_position()
	#mouse.position = mouse_position
	mouse.position = mouse_position
	
	if Input.is_action_pressed("action_debug"):
		_debug_follow()

func _debug_follow() -> void:
	debug_container.position = (mouse.position + debug_offset) - (debug_container.size / 2)

func _debug_hide() -> void:
	pass

func show_mouse() -> void:
	#mouse.scale = Vector2(0, 0)
	var tween = create_tween()
	tween.tween_property(mouse, "scale", Vector2(2.5, 2.5), 0.1)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)

func hide_mouse() -> void:
	#mouse.scale = Vector2(1, 1)
	var tween = create_tween()
	tween.tween_property(mouse, "scale", Vector2(0, 0), 0.1)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
