extends CanvasLayer

signal main_menu_enter

@onready var quit_confirm : Control = $QuitConfirm
@onready var blur_rect : Control = $BlurRect
@onready var anim : AnimationPlayer = $VSplitContainer/MarginContainer2/Label/AnimationPlayer

var popup_up : bool = false

func play() -> void:
	await get_tree().create_timer(0.5).timeout
	anim.play("fade_in")

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("action_enter"):
		main_menu_enter.emit()
	if Input.is_action_just_pressed("action_escape"):
		if popup_up:
			_on_quit_confirm_cancel_button_up()
		else:
			popup_up = true
			var tween = get_tree().create_tween()
			tween.set_parallel(true)
			tween.tween_property(quit_confirm, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_method(_set_blur_amount, 0.0, 2.0, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_method(_set_mix_amount, 0.0, 0.5, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func kill_self() -> void:
	queue_free()

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
