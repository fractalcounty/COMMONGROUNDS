extends Camera2D
class_name TopdownCamera2D

@export var pcam: PhantomCamera2D
@export var default_offset: Vector2 = Vector2.ZERO
@export_group("Dragging")
@export var drag_reset_duration: float = 2.0
@export_group("Panning")
@export var pan_speed: float = 0.0
@export var pan_acceleration: float = 0.0
@export var pan_reset_threshold: float = 0.0
@export var pan_reset_speed: float = 0.0
@export var pan_reset_trans: Tween.TransitionType = Tween.TRANS_SINE
@export var pan_reset_ease: Tween.EaseType = Tween.EASE_OUT

enum ControllerState {LOCKED, PANNING, DRAGGING, LOCKING}
var last_controller_state: ControllerState = ControllerState.LOCKED
var current_controller_state: ControllerState = ControllerState.LOCKED

var movement_direction: Vector2
var pan_direction: Vector2
var is_offset_effectively_zero : bool = false
var pan_toggled: bool = false

enum CameraState { IDLE, DRAGGING, AWAY, RESETTING }
var state: CameraState = CameraState.IDLE
var last_state: CameraState = CameraState.IDLE
var initial_camera_offset: Vector2
var initial_mouse_position: Vector2
@onready var drag_reset_timer: Timer = Timer.new()

@onready var _log : LogStream = LogStream.new("Camera2D", Global.camera_log_level)
@onready var tween: Tween = get_tree().create_tween()

func _ready() -> void:
	add_child(drag_reset_timer)
	drag_reset_timer.wait_time = drag_reset_duration
	drag_reset_timer.one_shot = true
	drag_reset_timer.timeout.connect(_on_drag_reset_timer_timeout)

func _input(event: InputEvent) -> void:
	movement_direction = Input.get_vector("action_move_left", "action_move_right", "action_move_up", "action_move_down")
	pan_direction = Input.get_vector("action_pan_left", "action_pan_right", "action_pan_up", "action_pan_down")
	
	_controller_state_transition()
	
	if Input.is_action_pressed("action_reset"):
		change_state(CameraState.RESETTING)

func change_state(new_state: CameraState) -> void:
	last_state = state
	state = new_state
	if last_state != new_state:	
		match new_state:
			CameraState.IDLE:
				InputManager.mouse.change_cursor_shape(InputManager.mouse.MouseCursorShape.ARROW)
			CameraState.DRAGGING:
				InputManager.mouse.change_cursor_shape(InputManager.mouse.MouseCursorShape.MOVE)
			CameraState.AWAY:
				InputManager.mouse.change_cursor_shape(InputManager.mouse.MouseCursorShape.ARROW)
			CameraState.RESETTING:
				InputManager.mouse.change_cursor_shape(InputManager.mouse.MouseCursorShape.ARROW)
			

func _physics_process(delta: float) -> void:
	is_offset_effectively_zero = true if pcam.get_follow_target_offset().distance_to(Vector2.ZERO) < pan_reset_threshold else false
	if current_controller_state in [ControllerState.DRAGGING, ControllerState.PANNING]:
		_pan(delta)
	if current_controller_state in [ControllerState.LOCKING, ControllerState.DRAGGING]:
		_reset(delta)
	_controller_state_transition()
	
	match state:
		CameraState.IDLE:
			if Input.is_action_pressed('action_drag'):
				initial_mouse_position = get_global_mouse_position()
				initial_camera_offset = pcam.get_follow_target_offset()
				change_state(CameraState.DRAGGING)
			#_log.info("CameraState: IDLE, offset: " + str(pcam.get_follow_target_offset()) + ", default: " + str(default_offset))
		CameraState.DRAGGING:
			if Input.is_action_pressed('action_drag'):
				var current_mouse_position = get_global_mouse_position()
				var drag_delta = current_mouse_position - initial_mouse_position
				pcam.set_follow_target_offset(initial_camera_offset - drag_delta)
			else:
				drag_reset_timer.start()
				change_state(CameraState.AWAY)
			#_log.info("CameraState: DRAGGING, offset: " + str(pcam.get_follow_target_offset()) + ", default: " + str(default_offset))
		CameraState.AWAY:
			#_log.info("CameraState: AWAY, offset: " + str(pcam.get_follow_target_offset()) + ", default: " + str(default_offset))
			if Input.is_action_pressed('action_drag'):
				initial_mouse_position = get_global_mouse_position()
				initial_camera_offset = pcam.get_follow_target_offset()
				change_state(CameraState.DRAGGING)
		CameraState.RESETTING:
			#_log.info("CameraState: RESETTING, offset: " + str(pcam.get_follow_target_offset()) + ", default: " + str(default_offset))
			if Input.is_action_pressed('action_drag'):
				initial_mouse_position = get_global_mouse_position()
				initial_camera_offset = pcam.get_follow_target_offset()
				change_state(CameraState.DRAGGING)
			else:
				_reset(delta)

func _drag() -> void:
	initial_mouse_position = get_global_mouse_position()
	initial_camera_offset = pcam.get_follow_target_offset()
	drag_reset_timer.stop()
	InputManager.mouse.change_cursor_shape(InputManager.mouse.MouseCursorShape.MOVE)

func _on_drag_reset_timer_timeout() -> void:
	state = CameraState.RESETTING


func _reset(delta: float) -> void:
	var current_offset: Vector2 = pcam.get_follow_target_offset()
	var delta_offset: Vector2 = default_offset - current_offset
	var duration: float = pan_reset_speed * delta  # pan_reset_speed should be total reset time in seconds (not a speed)

	var resetting_offset = tween.interpolate_value(
		current_offset,
		delta_offset,
		delta,
		duration,
		pan_reset_trans,  # Specify transition type
		pan_reset_ease   # Specify ease type
	)

	pcam.set_follow_target_offset(resetting_offset)
	
	if is_offset_effectively_zero:
		state = CameraState.IDLE

#region controller states
func _controller_state_transition():
	last_controller_state = current_controller_state
	var is_panning: bool = pan_direction != Vector2.ZERO
	var is_moving: bool = movement_direction != Vector2.ZERO
	
	match current_controller_state:
		ControllerState.LOCKED:
			if is_panning:
				current_controller_state = ControllerState.PANNING
				
		ControllerState.PANNING: # Holding pan
			if not is_panning:
				if last_controller_state == ControllerState.DRAGGING:
					current_controller_state = ControllerState.LOCKING
				elif is_moving:
					current_controller_state = ControllerState.LOCKING
			elif is_moving:
				current_controller_state = ControllerState.DRAGGING
		ControllerState.DRAGGING: # Holding pan and moving
			if not is_panning:
				if not is_moving:
					current_controller_state = ControllerState.LOCKING
				else:
					current_controller_state = ControllerState.LOCKING
			elif not is_moving:
				current_controller_state = ControllerState.PANNING
				
		ControllerState.LOCKING: # Released pan
			if is_offset_effectively_zero:
				current_controller_state = ControllerState.LOCKED
			elif is_panning:
				current_controller_state = ControllerState.DRAGGING if is_moving else ControllerState.PANNING

	if last_controller_state != current_controller_state:
		_log.debug("Changing to state: %s" % current_controller_state)

func _pan(delta: float) -> void:
	var pan_velocity = pan_direction.normalized() * pan_acceleration
	pcam.set_follow_target_offset(pcam.get_follow_target_offset() + pan_velocity * pan_speed * delta)
#endregion
