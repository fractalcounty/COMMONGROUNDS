extends CharacterBody2D
class_name Player

@export var speed : float = 100
@export var acceleration : float = 10
@onready var collision : CollisionShape2D = $CollisionShape2D

@onready var visual : PlayerVisualComponent = $PlayerVisualComponent
@onready var name_tag : RichTextLabel = $PlayerVisualComponent/NameTag

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("action_debug"):
		visual.debug_container.show()
	if Input.is_action_just_released("action_debug"):
		visual.debug_container.hide()

func _physics_process(_delta):
	var direction : Vector2 = Input.get_vector("action_left", "action_right", "action_up", "action_down")
	visual.update_animation(direction)
		
	velocity.x = move_toward(velocity.x, speed * direction.x, acceleration)
	velocity.y = move_toward(velocity.y, speed * direction.y, acceleration)
		
	move_and_slide()

func set_player_name(player_name: String):
	name_tag.text = "[jump][center]%s[/center][/jump]" % player_name

func stop_player() -> void:
	velocity = Vector2.ZERO  # Stop moving
	visual.reset_animation()  # Reset animation to idle or neutral state
	move_and_slide()  # Apply the zero velocity to stop the player
