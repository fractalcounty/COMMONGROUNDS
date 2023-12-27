class_name PlayerVisualComponent
extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $Body
@onready var name_tag: RichTextLabel = $NameTag
@onready var player_stats: PlayerStats = get_parent().player_stats
@export var tag_offset: Vector2 = Vector2(0, -170)

var last_ver_direction: float = 0
var was_moving_horiz: bool = false
var last_horiz_direction: float = 0  # New variable to track the last horizontal direction

func _ready():
	set_name_tag_text()
	anim.play("idle_down")

func _physics_process(delta: float) -> void:
	update_name_tag_position()

func set_name_tag_text():
	name_tag.text = "[jump][center]%s[/center][/jump]" % player_stats.username

func update_name_tag_position():
	name_tag.position = (sprite.position + tag_offset) - (name_tag.size / 2)

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

func apply_sprite_flip(moving_dir: Vector2):
	sprite.flip_h = moving_dir.x < 0 if moving_dir.x != 0 else sprite.flip_h
