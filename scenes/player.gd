extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed: float = 14.0
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration: float = 75.0

var target_velocity: Vector3 = Vector3.ZERO

@export var sprite: AnimatedSprite3D

@export var camera : Camera3D

func _physics_process(delta: float) -> void:
	var direction: Vector3 = Vector3.ZERO

	if camera:
		if Input.is_action_pressed("move_right"):
			direction += camera.global_transform.basis.x
		if Input.is_action_pressed("move_left"):
			direction -= camera.global_transform.basis.x
		if Input.is_action_pressed("move_down"):
			direction += camera.global_transform.basis.z
		if Input.is_action_pressed("move_up"):
			direction -= camera.global_transform.basis.z

	direction.y = 0 # Keep movement in the horizontal plane
	direction = direction.normalized()

	if direction != Vector3.ZERO:
		update_sprite_animation(direction)
		# Ground Velocity
		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed
	else:
		# Reset horizontal velocity and stop the sprite animation when there is no input
		target_velocity.x = 0.0
		target_velocity.z = 0.0
		sprite.stop()

	# Vertical Velocity
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta
	else:
		target_velocity.y = 0.0

	# Set the linear velocity
	velocity = target_velocity

	# Call move_and_slide without arguments
	move_and_slide()

func update_sprite_animation(direction: Vector3) -> void:
	var direction_2d = Vector2(direction.x, direction.z)

	if abs(direction.x) > abs(direction.z):
		# Horizontal movement
		sprite.animation = "side"
		sprite.flip_h = -direction.x < 0  # Flip horizontally if moving left
	else:
		# Vertical movement
		if direction.z < 0:
			sprite.animation = "down"
		else:
			sprite.animation = "up"

	if not sprite.is_playing():
		sprite.play()

