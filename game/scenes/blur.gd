extends ColorRect

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var tint : Color = Color.BLACK

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

func _on_visibility_changed() -> void:
	anim.play("fade_in") if visible else anim.play("fade_out")
