class_name Actor
extends CharacterBody2D

@export var speed : float = 100
@export var acceleration : float = 10
@export var username : String = 'username'
@onready var collision : CollisionShape2D = $CollisionShape2D

@onready var visual : ActorVisualComponent = $VisualComponent

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
