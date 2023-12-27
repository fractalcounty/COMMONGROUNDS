extends Control

@onready var quit_confirmation_dialog : ConfirmationDialog = $QuitConfirmationDialog
var popup_visible : bool = false

func _ready() -> void:
	quit_confirmation_dialog.hide()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		quit_confirmation_dialog.show()

#func _blur_in() -> void:
	#add_child(blur_rect)
	#show()
	#var tween = get_tree().create_tween()
	#tween.set_parallel(true)
	##tween.tween_property(quit_confirm, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
#
#func _blur_out() -> void:
	#var tween = get_tree().create_tween()
	#tween.set_parallel(true)
	##tween.tween_property(quit_confirm, "scale", Vector2(0, 0), 0.05).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	#tween.tween_method(_set_blur_amount, 2.0, 0.0, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	#tween.tween_method(_set_mix_amount, 0.5, 0.0, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	#tween.tween_callback(hide)

func _on_popup_visibility_changed() -> void:
	if quit_confirmation_dialog.visible:
		popup_visible = true
	else:
		popup_visible = false
