extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	SceneManager.loading_screen_ready.emit()

func fade_out_loading_screen() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	SceneManager.loading_screen_exit.emit()
	SceneManager.loading_screen_instance = null
	queue_free()
