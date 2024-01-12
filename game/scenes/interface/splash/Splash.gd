extends CanvasLayer

signal finished

@export_range(0.0, 30.0, 1.0, "suffix:s") var delay_after_splash : float

@onready var splash_player : VideoStreamPlayer = $CenterContainer/VideoStreamPlayer

func _ready() -> void:
	pass

func _on_video_stream_player_finished():
	await get_tree().create_timer(delay_after_splash).timeout
	finished.emit()
