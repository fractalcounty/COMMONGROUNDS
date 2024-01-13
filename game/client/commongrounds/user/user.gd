extends CharacterBody2D
class_name User

@export var speed : float = 100
@export var acceleration : float = 10
@onready var collision : CollisionShape2D = $CollisionShape2D

@onready var visual : UserVisualComponent = $UserVisualComponent
@onready var name_tag : RichTextLabel = $UserVisualComponent/NameTag
@onready var username : String = "username"

var target_pos : Vector2 = Vector2()

func _ready() -> void:
	pass

func _physics_process(_delta):
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

func set_target_position(target_position: Vector2):
	target_pos = target_position

func set_player_name(player_name: String):
	name_tag.text = "[jump][center]%s[/center][/jump]" % player_name

func stop_user() -> void:
	velocity = Vector2.ZERO  # Stop moving
	visual.reset_animation()  # Reset animation to idle or neutral state
	move_and_slide()  # Apply the zero velocity to stop the player
