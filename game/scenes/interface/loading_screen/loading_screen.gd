extends CanvasLayer

@onready var anim : AnimationPlayer = $AnimationPlayer

signal fade_in_finished
signal fade_out_finished

func _ready() -> void:
	anim.current_animation = "RESET"

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		fade_in_finished.emit()
	if anim_name == "fade_out":
		fade_out_finished.emit()

func fade_in() -> void:
	anim.play("fade_in")

func fade_out() -> void:
	anim.play("fade_out")