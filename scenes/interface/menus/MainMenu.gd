extends CanvasLayer

@onready var quit_confirm : Control = $QuitConfirm
@onready var blur_rect : Control = $BlurRect
var popup_up : bool = false

func _ready() -> void:
	pass

func _on_start_mouse_entered() -> void:
	pass
	#GameManager.interface.on_button_hover()

func _on_exit_mouse_entered() -> void:
	pass
	#GameManager.interface.on_button_hover()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("action_enter"):
		get_parent().post_processing.queue_free()
		get_parent().game.load_world(self)
	if Input.is_action_just_pressed("action_escape"):
		if popup_up == true:
			_on_quit_confirm_cancel_button_up()
		else:
			popup_up = true
			var tween = get_tree().create_tween()
			tween.set_parallel(true)
			tween.tween_property(quit_confirm, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_method(_set_blur_amount, 0.0, 2.0, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_method(_set_mix_amount, 0.0, 0.5, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _set_blur_amount(value: float):
	blur_rect.material.set_shader_parameter("blur_amount", value)

func _set_mix_amount(value: float):
	blur_rect.material.set_shader_parameter("mix_amount", value)

func _on_quit_confirm_ok_button_up() -> void:
	get_tree().quit()

func _on_quit_confirm_cancel_button_up() -> void:
	popup_up = false
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(quit_confirm, "scale", Vector2(0, 0), 0.05).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_blur_amount, 2.0, 0.0, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_mix_amount, 0.5, 0.0, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
