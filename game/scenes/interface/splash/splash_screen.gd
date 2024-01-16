extends CanvasLayer

signal video_finished
signal fade_finished

@onready var video_stream_player : VideoStreamPlayer = $ColorRect/CenterContainer/VideoStreamPlayer

func _ready() -> void:
	video_stream_player.finished.connect(_on_video_stream_player_finished)

func _on_video_stream_player_finished() -> void:
	emit_signal("video_finished")
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($ColorRect, "modulate:a", 0, 0.5)
	tween.tween_callback(_on_tween_finished)

func _on_tween_finished() -> void:
	emit_signal("fade_finished")
	queue_free()
