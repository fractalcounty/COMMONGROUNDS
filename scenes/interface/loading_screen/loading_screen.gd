extends CanvasLayer

@onready var anim : AnimationPlayer = $AnimationPlayer

signal safe
signal sortadone
signal done

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		safe.emit()
	if anim_name == "fade_out":
		done.emit()

func fade_in() -> void:
	anim.play("fade_in")

func fade_out() -> void:
	anim.play("fade_out")
	


func _on_anim_changed(old_name: StringName, new_name: StringName) -> void:
	if old_name == "fade_in" and new_name == "fade_out":
		sortadone.emit()
