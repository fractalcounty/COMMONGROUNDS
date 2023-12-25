extends CanvasLayer

signal finished
@onready var control : Control = $Control
@onready var animation_player : AnimationPlayer = $Control/AnimationPlayer
@onready var loading_container : MarginContainer = $Control/LoadingContainer

func _on_animation_finish(anim_name: StringName) -> void:
	if anim_name == "splash":
		finished.emit()
