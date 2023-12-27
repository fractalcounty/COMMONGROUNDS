extends Control

@onready var blur_rect : ColorRect = preload("res://scenes/interface/menus/BlurRect.tscn").instantiate()

func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		print("ui_cancel")
		if visible:
			print("blur out")
			_blur_out()
		else:
			print("blur in")
			_blur_in()

func _blur_in() -> void:
	add_child(blur_rect)
	show()
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	#tween.tween_property(quit_confirm, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_blur_amount, 0.0, 2.0, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_mix_amount, 0.0, 0.5, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _blur_out() -> void:
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	#tween.tween_property(quit_confirm, "scale", Vector2(0, 0), 0.05).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_blur_amount, 2.0, 0.0, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_mix_amount, 0.5, 0.0, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(hide)

func _set_blur_amount(value: float) -> void:
	blur_rect.material.set_shader_parameter("blur_amount", value)

func _set_mix_amount(value: float) -> void:
	blur_rect.material.set_shader_parameter("mix_amount", value)
