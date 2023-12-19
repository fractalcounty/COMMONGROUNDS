extends Camera3D

@export var camera_base : Marker3D
@export var offset: Vector3 = Vector3(0, 10, -10)  # Camera's offset from the player
@export var look_at_offset: Vector3 = Vector3(0, 1, 0)  # Offset for where the camera should look at

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensure the camera is in the correct initial position
	update_camera_position()
	# Set the camera to an orthogonal projection if needed
	#projection = PROJECTION_ORTHOGONAL
	#size = 5.0  # Adjust as needed for the desired view size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_camera_position()

func update_camera_position() -> void:
	# Position the camera at the specified offset relative to the player
	global_transform.origin = camera_base.global_transform.origin + offset
	# Make the camera look at the player, considering the look_at offset
	look_at(camera_base.global_transform.origin + look_at_offset, Vector3.UP)
