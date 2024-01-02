class_name Actor
extends CharacterBody2D

@export var speed : float = 100
@export var acceleration : float = 10
@export var username : String = 'cheeseburger69'
@onready var collision : CollisionShape2D = $CollisionShape2D

@onready var visual : ActorVisualComponent = $VisualComponent

func _ready() -> void:
	Chat.username = username
	Chat.actor = self

func _input(event: InputEvent) -> void:
	if not Chat.focused:
		if Input.is_action_just_pressed("action_debug"):
			visual.debug_container.show()
		if Input.is_action_just_released("action_debug"):
			visual.debug_container.hide()

func _physics_process(_delta):
	if not Chat.focused:
		var direction : Vector2 = Input.get_vector("action_left", "action_right", "action_up", "action_down")
		visual.update_animation(direction)
		
		velocity.x = move_toward(velocity.x, speed * direction.x, acceleration)
		velocity.y = move_toward(velocity.y, speed * direction.y, acceleration)
		
		move_and_slide()
	else:
		# Stop the player and reset animation when chat is focused
		stop_player()

func stop_player():
	velocity = Vector2.ZERO  # Stop moving
	visual.reset_animation()  # Reset animation to idle or neutral state
	move_and_slide()  # Apply the zero velocity to stop the player
