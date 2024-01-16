extends Camera2D

@export var pcam: PhantomCamera2D
@export var default_offset: Vector2 = Vector2.ZERO
@export_group("Panning")
@export var pan_speed: float = 0.0
@export var pan_acceleration: float = 0.0
@export var pan_reset_threshold: float = 0.0
@export var pan_reset_speed: float = 0.0
@export var pan_reset_trans: Tween.TransitionType = Tween.TRANS_SINE
@export var pan_reset_ease: Tween.EaseType = Tween.EASE_OUT

enum State {LOCKED, PANNING, DRAGGING, LOCKING}

var movement_direction: Vector2
var pan_direction: Vector2
var last_state: State = State.LOCKED
var current_state: State = State.LOCKED
var is_offset_effectively_zero : bool = false
var pan_toggled: bool = false
@onready var _log : LogStream = LogStream.new("Camera2D", Global.camera_log_level)
@onready var tween: Tween = get_tree().create_tween()

func _input(event: InputEvent) -> void:
	movement_direction = Input.get_vector("action_move_left", "action_move_right", "action_move_up", "action_move_down")
	pan_direction = Input.get_vector("action_pan_left", "action_pan_right", "action_pan_up", "action_pan_down")
	
	_state_transition()

func _physics_process(delta: float) -> void:
	is_offset_effectively_zero = true if pcam.get_follow_target_offset().distance_to(Vector2.ZERO) < pan_reset_threshold else false
	if current_state in [State.DRAGGING, State.PANNING]:
		_pan(delta)
	if current_state in [State.LOCKING, State.DRAGGING]:
		_reset(delta)
	_state_transition()

func _state_transition():
	last_state = current_state
	var is_panning: bool = pan_direction != Vector2.ZERO
	var is_moving: bool = movement_direction != Vector2.ZERO
	
	match current_state:
		State.LOCKED:
			if is_panning:
				current_state = State.PANNING
				
		State.PANNING: # Holding pan
			if not is_panning:
				if last_state == State.DRAGGING:
					current_state = State.LOCKING
				elif is_moving:
					current_state = State.LOCKING
			elif is_moving:
				current_state = State.DRAGGING
		State.DRAGGING: # Holding pan and moving
			if not is_panning:
				if not is_moving:
					current_state = State.LOCKING
				else:
					current_state = State.LOCKING
			elif not is_moving:
				current_state = State.PANNING
				
		State.LOCKING: # Released pan
			if is_offset_effectively_zero:
				current_state = State.LOCKED
			elif is_panning:
				current_state = State.DRAGGING if is_moving else State.PANNING

	if last_state != current_state:
		_log.debug("Changing to state: %s" % current_state)

func _pan(delta: float) -> void:
	var pan_velocity = pan_direction.normalized() * pan_acceleration
	pcam.set_follow_target_offset(pcam.get_follow_target_offset() + pan_velocity * pan_speed * delta)

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
