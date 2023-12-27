extends CanvasLayer

signal main_menu_enter

@onready var game : Node
@onready var anim : AnimationPlayer = $MarginContainer4/Control/Label/AnimationPlayer
@onready var quit_confirmation_dialog = $QuitConfirmationDialog
var popup_visible : bool = false

func _ready() -> void:
	quit_confirmation_dialog.hide()

func play() -> void:
	await get_tree().create_timer(0.5).timeout
	anim.play("fade_in")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		main_menu_enter.emit()
	if Input.is_action_just_pressed("ui_cancel"):
		quit_confirmation_dialog.show()

func _on_quit_warning_visibility_changed() -> void:
	if quit_confirmation_dialog.visible:
		popup_visible = true
		EventManager.popup_visible.emit()
		#var tween = get_tree().create_tween()
		#tween.tween_property(quit_confirmation_dialog, "content_scale_size", Vector2i(244, 94), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	else:
		popup_visible = false
		EventManager.popup_hidden.emit()
