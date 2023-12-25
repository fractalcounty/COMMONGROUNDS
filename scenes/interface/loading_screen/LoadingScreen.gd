extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	pass

func fade_out_loading_screen() -> void:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	queue_free()
