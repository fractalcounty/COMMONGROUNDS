extends Node3D

var letters: Array
var mouse_ray_origin: Vector3
var mouse_ray_direction: Vector3
var rng: = RandomNumberGenerator.new()
@onready var cam: Camera3D = $Camera3D

# Camera movement variables
var viewport_size : Vector2
var original_camera_position : Vector3
var original_camera_rotation : Vector3
var target_position : Vector3
var target_rotation : Vector3

var movement_sensitivity : float = 0.0006
var rotation_sensitivity : float = 0.0006
var smoothing_factor : float = 0.04

func _ready():
	viewport_size = get_viewport().size
	original_camera_position = cam.global_transform.origin
	original_camera_rotation = cam.rotation_degrees
	target_position = original_camera_position
	target_rotation = original_camera_rotation
	
	letters = get_children()
	rng.randomize()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_offset = (event.position - viewport_size * 0.5) * movement_sensitivity
		target_position = original_camera_position + Vector3(mouse_offset.x, 0, mouse_offset.y)
		target_rotation = original_camera_rotation + Vector3(-mouse_offset.y * rotation_sensitivity, mouse_offset.x * rotation_sensitivity, 0)

func _physics_process(delta: float) -> void:
	cam.global_transform.origin = cam.global_transform.origin.lerp(target_position, smoothing_factor)
	cam.rotation_degrees = cam.rotation_degrees.lerp(target_rotation, smoothing_factor)

#func _process(_delta):
	#if Input.is_action_just_pressed("click"):
		#print("hooplah")
		#process_click()
#
#func process_click() -> void:
	#var mouse_pos = get_viewport().get_mouse_position()
	#mouse_ray_origin = cam.project_ray_origin(mouse_pos)
	#mouse_ray_direction = cam.project_ray_normal(mouse_pos)
#
#func _physics_process(delta: float) -> void:
	#var space_state = get_world_3d().direct_space_state
	#var ray_parameters = PhysicsRayQueryParameters3D.create(mouse_ray_origin, mouse_ray_origin + mouse_ray_direction * 1000)
	#var result = space_state.intersect_ray(ray_parameters)
#
	#if result and result.collider in letters:
		#print("hitting")
		#apply_force_to_letter(result.collider)
#
#func apply_force_to_letter(letter: PhysicsBody3D) -> void:
	## Launch the letter by applying a force
	## You might need to adjust these values depending on your game's needs
	#var force = Vector3(rng.randf_range(-100, 100), rng.randf_range(200, 300), rng.randf_range(-100, 100))
	#letter.apply_impulse(Vector3(), force)
