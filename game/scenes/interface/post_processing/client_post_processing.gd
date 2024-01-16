extends CanvasLayer

@onready var grain : ColorRect = $Grain
@onready var blur : ColorRect = $Blur
@onready var blur_out_color : Color = Color.TRANSPARENT
@export var blur_in_color : Color ## This is the variable I want to pass to the shader, the end result color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grain_in()

func _on_popup_hidden() -> void:
	blur_out()
	
func _on_popup_visible() -> void:
	blur_in()

func blur_in() -> void:
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_blur_amount, 0.0, 1.5, 0.5)  # Adjust the duration as needed
	tween.tween_method(_set_blur_color, blur_out_color, blur_in_color, 0.5)  # Same duration for color

func blur_out() -> void:
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_blur_amount, 1.5, 0.0, 0.5)  # Adjust the duration as needed
	tween.tween_method(_set_blur_color, blur_in_color, blur_out_color, 0.5)  # Same duration for color

func _set_blur_amount(value: float) -> void:
	blur.material.set_shader_parameter("blur_amount", value)
	
func _set_blur_color(value : Color) -> void:
	blur.material.set_shader_parameter("blur_color", value)

func grain_in() -> void:
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_grain_amount, 0.0, 0.002, 0.5)  # Adjust the duration as needed

func grain_out() -> void:
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_grain_amount, 0.002, 0.0, 0.5)  # Adjust the duration as needed
	await tween.finished
	grain.hide()

func _set_grain_amount(value: float) -> void:
	grain.material.set_shader_parameter("intensity", value)
