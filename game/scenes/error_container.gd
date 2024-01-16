extends CanvasLayer

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var tint : Color = Color.BLACK

@onready var header_label : Label = $ErrorScreen/MarginContainer/VBoxContainer/HeaderLabel
@onready var body_label : Label = $ErrorScreen/MarginContainer/VBoxContainer/BodyLabel
@onready var blur : ColorRect = $BlurRect
@export var blur_tint : Color = Color.BLACK
@export var critical_blur_tint : Color = Color.RED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

func show_error(header: String, body: String, critical: bool = false) -> void:
	header_label.text = header
	body_label.text = body
	show()
	if critical:
		blur.material.set_shader_parameter("color_over", critical_blur_tint)
	else:
		blur.material.set_shader_parameter("color_over", blur_tint)
		anim.play("fade_in")

func hide_error() -> void:
	Log.debug("Hiding error")
	anim.play("fade_out")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		hide()
