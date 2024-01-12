extends CanvasLayer

signal fade_in_finished
signal fade_out_finished
signal scene_visible
signal ng_connection_timed_out

var is_loading : bool = false

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var label : RichTextLabel = $LoadingContainer/RichTextLabel
@onready var err_label : Label = $CenterContainer/ErrorLabel

func _ready() -> void:
	Global.loading_screen = self
	anim.play("RESET")

func summon(msg: String) -> void:
	_set_text(msg)
	anim.play("fade_in")

func update(msg: String) -> void:
	_set_text(msg)
	anim.play("hold")

func banish(msg: String) -> void:
	_set_text(msg)
	anim.play("fade_out")

func _set_text(text: String) -> void:
	var final_text : String = "[wave amp=30.0 freq=3.0 connected=1]" + text + "[/wave]"
	label.text = final_text

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		is_loading = true
		fade_in_finished.emit()
		anim.play("hold")
	if anim_name == "fade_out":
		is_loading = false
		fade_out_finished.emit()
		anim.play("RESET")

func _on_new_scene_visible() -> void:
	scene_visible.emit()
