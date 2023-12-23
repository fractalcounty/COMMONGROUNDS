class_name TopdownPlayer3D extends CharacterBody3D
## A top-down player controller for 3D

@export_subgroup("Movement Properties")
@export var speed: float = 10.0
@export var fall_acceleration: float = 75.0
@export_range(1, 30, 1, "suffix:s") var time_till_idle : float = 8.0

@onready var camera: Camera3D = $OrthoCamera3D ## The camera node, child of the base
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var idle_timer : Timer = $IdleTimer ## Determines when the player does idle animation

# New properties for idle and sitting
var is_sitting: bool = false
var target_velocity: Vector3 = Vector3.ZERO
var last_direction: Vector3 = Vector3.ZERO  # Variable to store last direction

func _ready():
	idle_timer.wait_time = time_till_idle

func _physics_process(delta: float) -> void:
	var direction: Vector3 = Vector3.ZERO

	## Input handling
	if camera:
		if Input.is_action_pressed("move_right"):
			direction += camera.global_transform.basis.x
		if Input.is_action_pressed("move_left"):
			direction -= camera.global_transform.basis.x
		if Input.is_action_pressed("move_down"):
			direction += camera.global_transform.basis.z
		if Input.is_action_pressed("move_up"):
			direction -= camera.global_transform.basis.z

	direction.y = 0
	direction = direction.normalized()

	if direction != Vector3.ZERO:
		last_direction = direction  # Update last direction
		_update_sprite_animation(direction)
		if is_sitting:
			is_sitting = false
		idle_timer.start()
	else:
		if not is_sitting:
			_play_idle_animation()  # Play corresponding idle animation

	## Horizontal Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	## Vertical Velocity
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta
	else:
		target_velocity.y = 0.0

	velocity = target_velocity
	move_and_slide()

func _update_sprite_animation(direction: Vector3) -> void:

	if abs(direction.x) > abs(direction.z):
		anim.play("walk_side")
		sprite.flip_h = -direction.x < 0
	elif direction.z > 0:
		anim.play("walk_up")
	else:
		anim.play("walk_down")

func _play_idle_animation() -> void:
	if abs(last_direction.x) > abs(last_direction.z):
		anim.play("still_side")
		sprite.flip_h = -last_direction.x < 0
	elif last_direction.z > 0:
		anim.play("still_up")
	else:
		anim.play("still_down")

func _on_idle_timer_timeout() -> void:
	is_sitting = true
	anim.play("sit")
