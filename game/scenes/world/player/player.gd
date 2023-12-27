class_name Player
extends CharacterBody2D

@export var player_stats: PlayerStats
@export var speed : float = 100
@export var acceleration : float = 10
@onready var collision : CollisionShape2D = $CollisionShape2D

@onready var visual : PlayerVisualComponent = $VisualComponent

func _physics_process(_delta):
	var direction : Vector2 = Input.get_vector("action_left", "action_right", "action_up", "action_down")
	visual.update_animation(direction)
	
	velocity.x = move_toward(velocity.x, speed * direction.x, acceleration)
	velocity.y = move_toward(velocity.y, speed * direction.y, acceleration)
	
	move_and_slide()
