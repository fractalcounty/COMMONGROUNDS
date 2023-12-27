@icon("res://resources/icons/ortho_camera_3d.svg")
class_name OrthoCamera3D extends Camera3D
## A top-down 3D camera that works well with tilesests
##
## Has support for zooming and other features eventually

# TODO: F3 menu support.

@export_subgroup("General Properties")
@export var camera_follow_speed : float = 5.0 ## Speed at which camera follows the player
@export var offset: Vector3 = Vector3(0, 10, -10)
@export var look_at_offset: Vector3 = Vector3(0, 1, 0)

@export_subgroup("Zoom Properties")
@export_range(1, 28, 1) var default_zoom : float = 12.0  ## Resting camera zoom level (resets to this)
@export_range(1, 20, 1, "suffix:s") var reset_time : float = 5.0 ## Seconds it takes for the camera to reset to default
@export_range(1, 16, 1) var min_zoom: float = 8.0 ## Minimum value the camera can zoom out to
@export_range(1, 28, 1) var max_zoom: float = 20.0 ## Maximum value that the camera can zoom in to
@export_range(1, 10, 1) var zoom_increment : float = 3.0 ## Value by which the camera zooms when scrolling
@export var zoom_speed : float = 8.0 ## The speed at which the camera zooms when scrolling

@onready var reset_timer : Timer = $ResetTimer
@onready var player : TopdownPlayer3D = get_parent()

var snap_threshold : float = 0.01
var current_zoom: float = default_zoom
var target_zoom: float = default_zoom

func _ready() -> void:
	_handle_camera_follow()
	size = current_zoom
	reset_timer.wait_time = reset_time

func _physics_process(delta: float) -> void:
	_handle_camera_follow()
	_handle_zoom(delta)

func _handle_camera_follow() -> void:
	global_transform.origin = player.global_transform.origin + offset
	look_at(player.global_transform.origin + look_at_offset, Vector3.UP)

func _handle_zoom(delta: float) -> void:
	if Input.is_action_just_pressed("action_zoom_in"):
		target_zoom = max(floor(current_zoom) - zoom_increment, min_zoom)
		reset_timer.start()
	elif Input.is_action_just_pressed("action_zoom_out"):
		target_zoom = min(ceil(current_zoom) + zoom_increment, max_zoom)
		reset_timer.start()

	current_zoom = lerp(current_zoom, target_zoom, delta * zoom_speed)
	size = current_zoom

	if abs(current_zoom - target_zoom) < snap_threshold:
		current_zoom = target_zoom
		size = target_zoom

func _on_reset_timer_timeout() -> void:
	target_zoom = default_zoom
