extends CharacterBody2D
class_name User

@export var speed : float = 100
@export var acceleration : float = 10
@onready var collision : CollisionShape2D = $CollisionShape2D

@onready var visual : UserVisualComponent = $UserVisualComponent
@onready var name_tag : RichTextLabel = $UserVisualComponent/NameTag
@onready var username : String = "username"

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $Body
@export var tag_offset: Vector2 = Vector2(0, -170)
@onready var speech : VBoxContainer = $Speech

@onready var skeleton : Skeleton2D = $Skeleton2D

var icon : String = ""
var supporter : bool

var direction : Vector2

#If you've allowed 'Resizable' under Display settings you'll need to directly grab this in the _process
@onready var screen_dimensions : Vector2 = Vector2(get_viewport().size)

var last_ver_direction: float = 0
var was_moving_horiz: bool = false
var last_horiz_direction: float = 0  # New variable to track the last horizontal direction

func set_icon(_icon: String) -> void:
	_icon = icon

func set_supporter(_supporter: bool) -> void:
	_supporter = supporter

func _physics_process(delta: float) -> void:
	name_tag.position = (sprite.position + tag_offset) - (name_tag.size / 2)
	var direction : Vector2 = target_pos - position
	if direction.length() < 1:
		position = target_pos
		direction = Vector2()
	elif direction.length() > 40:
		position = target_pos
		direction = Vector2()
	else:
		direction = direction.normalized()
	
	visual.update_animation(direction)
	
	velocity.x = move_toward(velocity.x, speed * direction.x, acceleration)
	velocity.y = move_toward(velocity.y, speed * direction.y, acceleration)
		
	move_and_slide()

func _process(delta: float) -> void:
		
	var screen_dimensions : Vector2 = get_viewport().size
	var player_gawdsdlobal_position : Vector2 = sprite.global_position
	var camera_global_position : Vector2 = Global.camera_position  # Assuming the camera script is attached to a node named Camera2DPlus
	var relative_position : Vector2 = player_global_position - camera_global_position
	var player_position_uv : Vector2 = (relative_position + Vector2(0, -50) + screen_dimensions / 2.0) / screen_dimensions
	RenderingServer.global_shader_parameter_set("player_position", player_position_uv)

func set_name_tag_text(username: String):
	name_tag.text = "[jump][center]%s[/center][/jump]" % username

func update_animation(moving_direction: Vector2):
	determine_animation(moving_direction)
	apply_sprite_flip(moving_direction)

func determine_animation(moving_dir: Vector2):
	var animation_name = get_animation_name(moving_dir)
	if anim.current_animation != animation_name:
		anim.play(animation_name)

func get_animation_name(moving_dir: Vector2) -> String:
	if moving_dir != Vector2.ZERO:
		update_last_ver_direction(moving_dir.y)
		update_last_horiz_direction(moving_dir.x)
		return get_moving_animation_name(moving_dir)
	else:
		return get_idle_animation_name()

func update_last_ver_direction(y_dir: float):
	if y_dir != 0:
		last_ver_direction = y_dir

func update_last_horiz_direction(x_dir: float):
	was_moving_horiz = x_dir != 0
	if x_dir != 0:
		last_horiz_direction = x_dir

func get_moving_animation_name(moving_dir: Vector2) -> String:
	if moving_dir.y > 0:
		return "move_down"
	elif moving_dir.y < 0:
		return "move_up"
	else:
		return "move_side"

func get_idle_animation_name() -> String:
	if was_moving_horiz:
		return "idle_side"
	else:
		return "idle_up" if last_ver_direction < 0 else "idle_down"

func reset_animation():
	# Determine the correct idle animation based on the last movement direction
	var idle_anim = get_idle_animation_name()

	# Play the idle animation if it's not already playing
	if anim.current_animation != idle_anim:
		anim.play(idle_anim)

func apply_sprite_flip(moving_dir: Vector2):
	sprite.flip_h = moving_dir.x < 0 if moving_dir.x != 0 else sprite.flip_h
	
var target_pos : Vector2 = Vector2()

func set_target_position(target_position: Vector2):
	target_pos = target_position

func set_player_name(username: String):
	await get_tree().create_timer(1.0).timeout
	name_tag.text = "[jump][center]%s[/center][/jump]" % username

func stop_user() -> void:
	velocity = Vector2.ZERO  # Stop moving
	visual.reset_animation()  # Reset animation to idle or neutral state
	move_and_slide()  # Apply the zero velocity to stop the player
