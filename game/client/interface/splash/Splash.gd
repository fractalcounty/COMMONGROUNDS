extends Control

signal finished

@export_range(0.0, 30.0, 1.0, "suffix:s") var delay_after_splash : float = 1.0

@onready var splash_player : VideoStreamPlayer = $CenterContainer/VideoStreamPlayer
@onready var anim : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	pass

func _on_video_stream_player_finished():
	await get_tree().create_timer(delay_after_splash).timeout
	finished.emit()
	anim.play("fade_out")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		queue_free()
