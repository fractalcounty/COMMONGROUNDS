extends CharacterBody2D
class_name Player

@export_subgroup("Physics")
@export var speed : float = 100
@export var acceleration : float = 10
@export_subgroup("Visuals")
@export var nametag_offset: Vector2 = Vector2(0, -170)
@export_range(0, 360, 1, "degrees") var head_max_rotation = 25.0
@export_range(0.1, 1, 0.001, "suffix:s") var head_rotation_duration: float = 0.25
@export var head_rotation_trans: Tween.TransitionType = Tween.TRANS_EXPO
@export var head_rotation_ease: Tween.EaseType = Tween.EASE_OUT
@export_range(0.1, 5, 0.01, "suffix:s") var head_rotation_reset_delay: float = 0.5
@export_subgroup("Camera")
@export var pcam: PhantomCamera2D
@export var zoom_step: float = 0.25
@export var max_zoom: Vector2 = Vector2(2, 2)
@export var min_zoom: Vector2 = Vector2(0.5, 0.5)
@export var zoom_duration: float = 0.25
@export var zoom_trans: Tween.TransitionType = Tween.TRANS_SINE
@export var zoom_ease: Tween.EaseType = Tween.EASE_OUT

var supporter : bool = false
var id : int = false
var icon : String = ""
var direction : Vector2
var is_moving: bool = false
var head_angle : float = 0.0
var current_zoom: Vector2 = Vector2(1, 1)
var input_direction_changed : bool = false
var is_flipped: bool = false
var mouse_moved: bool = false
var flip_delay : float = 0.0
var flip_delay_duration : float = 0.2

@onready var nametag : RichTextLabel = $NameTag
@onready var visual: Node2D = $VisualComponent
@onready var head_sprites: Node2D = $VisualComponent/HeadSprites
@onready var head_rotation_timer: Timer = Timer.new()

func update(_username: String = "", _supporter: bool = false, _icon: String = ""):
	self.name = _username
	nametag.text = "[jump][center]%s[/center][/jump]" % _username
	supporter = _supporter
	icon = _icon

func _ready() -> void:
	add_child(head_rotation_timer)
	head_rotation_timer.wait_time = head_rotation_reset_delay
	head_rotation_timer.one_shot = true
	head_rotation_timer.timeout.connect(_reset_head_rotation)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_moved = true
		head_rotation_timer.start()

func _process(delta: float) -> void:
	if mouse_moved:
		_rotate_head_to_mouse()
		_flip_direction_based_on_mouse()
		mouse_moved = false
		
	_handle_zoom_input()

func _physics_process(_delta):
	nametag.position = ($VisualComponent/HeadSprites/Head.position + nametag_offset) - (nametag.size / 2)
	
	var _direction : Vector2 = Input.get_vector("action_move_left", "action_move_right", "action_move_up", "action_move_down")	
	velocity.x = move_toward(velocity.x, speed * direction.x, acceleration)
	velocity.y = move_toward(velocity.y, speed * direction.y, acceleration)

	if _direction.length() != 0:
		is_moving = true
	else:
		is_moving = false
	
	if _direction.x != 0:
		visual.scale.x = abs(visual.scale.x) * sign(_direction.x)
		is_flipped = (visual.scale.x < 0)
		input_direction_changed = true
		
	direction = _direction
		
	move_and_slide()
	_flip_direction_based_on_movement()

func _flip_direction_based_on_movement() -> void:
	if is_moving:
		if direction.x < 0 and visual.scale.x > 0:
			visual.scale.x *= -1
			is_flipped = true
		elif direction.x > 0 and visual.scale.x < 0:
			visual.scale.x *= -1
			is_flipped = false

func _reset_head_rotation() -> void:
	if not mouse_moved and input_direction_changed:
		var tween = create_tween()
		tween.tween_property(head_sprites, "rotation", 0, head_rotation_duration)
		tween.set_ease(head_rotation_ease).set_trans(head_rotation_trans)
		input_direction_changed = false

func _rotate_head_to_mouse() -> void:
	if not input_direction_changed and mouse_moved:
		var head_position: Vector2 = head_sprites.get_global_transform().get_origin()
		var mouse_position: Vector2 = get_global_mouse_position()
		var heading_to_mouse : Vector2
		var desired_angle : float

		if is_flipped:
			heading_to_mouse = mouse_position - head_position
			heading_to_mouse.y = heading_to_mouse.y
			desired_angle = atan2(heading_to_mouse.y, -heading_to_mouse.x)
		else:
			heading_to_mouse = mouse_position - head_position
			desired_angle = atan2(heading_to_mouse.y, heading_to_mouse.x)

		head_angle = clamp(rad_to_deg(desired_angle), -head_max_rotation, head_max_rotation)

		var tween = create_tween()
		tween.tween_property(head_sprites, "rotation", deg_to_rad(head_angle), head_rotation_duration)
		tween.set_ease(head_rotation_ease).set_trans(head_rotation_trans)

func _flip_direction_based_on_mouse() -> void:
	if not input_direction_changed and not is_moving and mouse_moved:
		var mouse_position: Vector2 = get_global_mouse_position()
		var character_position: Vector2 = global_position

		if mouse_position.x < character_position.x and visual.scale.x > 0:
			visual.scale.x *= -1
			is_flipped = true
		elif mouse_position.x > character_position.x and visual.scale.x < 0:
			visual.scale.x *= -1
			is_flipped = false

	input_direction_changed = false

func _handle_zoom_input() -> void:
	if Input.is_action_just_pressed("action_zoom_in"):
		_zoom_in()
	elif Input.is_action_just_pressed("action_zoom_out"):
		_zoom_out()

func _calculate_adjusted_zoom_step(current_zoom: Vector2) -> float:
	# Adjust the zoom step exponentially based on the current zoom level
	return zoom_step * current_zoom.x

func _zoom_in() -> void:
	var current_zoom_level: Vector2 = pcam.get_zoom()
	var adjusted_zoom_step: float = _calculate_adjusted_zoom_step(current_zoom_level)
	var target_zoom: Vector2 = current_zoom_level - Vector2(adjusted_zoom_step, adjusted_zoom_step)
	target_zoom = target_zoom.clamp(min_zoom, max_zoom)
	_start_zoom_tween(target_zoom)

func _zoom_out() -> void:
	var current_zoom_level: Vector2 = pcam.get_zoom()
	var adjusted_zoom_step: float = _calculate_adjusted_zoom_step(current_zoom_level)
	var target_zoom: Vector2 = current_zoom_level + Vector2(adjusted_zoom_step, adjusted_zoom_step)
	target_zoom = target_zoom.clamp(min_zoom, max_zoom)
	_start_zoom_tween(target_zoom)

func _start_zoom_tween(target_zoom: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.tween_method(pcam.set_zoom, pcam.get_zoom(), target_zoom, zoom_duration).set_trans(zoom_trans).set_ease(zoom_ease)
