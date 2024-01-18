extends Control

signal active
signal inactive

@export_subgroup("Showing Tween")
@export var cursor_show_tween_amount: float = 0.25
@export var cursor_show_tween_duration: float = 0.25
@export var cursor_show_tween_ease_type: Tween.EaseType = Tween.EASE_OUT
@export var cursor_show_tween_trans_type: Tween.TransitionType = Tween.TRANS_BOUNCE
@export_subgroup("Hiding Tween")
@export var cursor_hide_tween_duration: float = 0.25
@export var cursor_hide_tween_ease_type: Tween.EaseType = Tween.EASE_IN
@export var cursor_hide_tween_trans_type: Tween.TransitionType = Tween.TRANS_BOUNCE
@export_subgroup("Bounce Tween")
@export var cursor_bounce_tween_amount: float = 0.25
@export var cursor_bounce_tween_duration: float = 0.25
@export var cursor_bounce_tween_ease_type: Tween.EaseType = Tween.EASE_OUT
@export var cursor_bounce_tween_trans_type: Tween.TransitionType = Tween.TRANS_BOUNCE

## Based on https://docs.godotengine.org/en/stable/classes/class_input.html#enumerations
enum MouseCursorShape {ARROW = 0, POINTING_HAND = 2, MOVE = 13, ZOOM = 14}
var change_cursor_visibility_based_on_activity: bool = true
var current_cursor_shape: MouseCursorShape = MouseCursorShape.ARROW
var last_cursor_shape: MouseCursorShape = MouseCursorShape.ARROW

var is_active: bool = false: set = _set_is_active

@onready var activity_timer: Timer = %ActivityTimer
@onready var cursor: TextureRect = %Cursor
@onready var cursor_debug_container: VBoxContainer = %CursorDebugContainer
@onready var cursor_debug_label_1: Label = %CursorDebugLabel1
@onready var cursor_debug_label_2: Label = %CursorDebugLabel2
@onready var screen_position: Vector2 = Vector2.ZERO
@onready var world_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	change_cursor_shape(MouseCursorShape.ARROW)
	activity_timer.timeout.connect(_on_activity_timer_timeout)

func _process(delta: float) -> void:
	#print(str(activity_timer.time_left) + ", " + str(is_active))
	screen_position = get_viewport().get_mouse_position()
	cursor.position = screen_position
	if cursor_debug_container.visible:
		cursor_debug_label_1.text = "screen_position: " + str(screen_position)
		cursor_debug_label_2.text = "world_position: " + str(world_position)

func change_cursor_shape(new_cursor_shape: MouseCursorShape) -> void:
	var animated_texture: AnimatedTexture = cursor.texture as AnimatedTexture
	last_cursor_shape = current_cursor_shape
	current_cursor_shape = new_cursor_shape
	match new_cursor_shape:
		MouseCursorShape.ARROW:
			animated_texture.set_current_frame(0)
		MouseCursorShape.POINTING_HAND:
			animated_texture.set_current_frame(1)
		MouseCursorShape.MOVE:
			animated_texture.set_current_frame(2)
		MouseCursorShape.ZOOM:
			animated_texture.set_current_frame(3)
	bounce_cursor()

func bounce_cursor() -> void:
	if is_active:
		var amount: Vector2 = Vector2(1, 1) + Vector2(cursor_bounce_tween_amount, cursor_bounce_tween_amount)
		var tween: Tween = create_tween()
	
		cursor.show()
		tween.tween_property(cursor, "scale", amount, cursor_bounce_tween_duration)
		tween.set_ease(cursor_bounce_tween_ease_type).set_trans(cursor_bounce_tween_trans_type)
		tween.tween_property(cursor, "scale", Vector2(1, 1), 0.3)
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		await tween.finished
		tween.kill()

func hide_cursor() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(cursor, "scale", Vector2(0, 0), cursor_hide_tween_duration)
	tween.set_ease(cursor_hide_tween_ease_type).set_trans(cursor_hide_tween_trans_type)
	
	await tween.finished
	tween.kill()

func show_cursor(persistent: bool = false) -> void:
	var amount: Vector2 = Vector2(1, 1) + Vector2(cursor_show_tween_amount, cursor_show_tween_amount)
	var tween: Tween = create_tween()

	cursor.show()
	tween.tween_property(cursor, "scale", amount, cursor_show_tween_duration)
	tween.set_ease(cursor_show_tween_ease_type).set_trans(cursor_show_tween_trans_type)
	tween.tween_property(cursor, "scale", Vector2(1, 1), 0.3)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	tween.kill()

func _set_is_active(new_value):
	if new_value == false and is_active == true and change_cursor_visibility_based_on_activity == true:
		hide_cursor()
	if new_value == true:
		activity_timer.start()
		active.emit()
		if is_active == false and change_cursor_visibility_based_on_activity == true:
			show_cursor()
	else:
		inactive.emit()
		
	is_active = new_value

func _on_activity_timer_timeout() -> void:
	is_active = false
