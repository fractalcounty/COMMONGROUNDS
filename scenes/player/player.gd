extends CharacterBody3D

var speed : float = 400

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var move_input := Input.get_axis("action_front", "action_back")
	velocity = direction * speed

	move_and_slide()
