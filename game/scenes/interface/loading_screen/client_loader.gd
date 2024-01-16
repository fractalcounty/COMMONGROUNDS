extends CanvasLayer

signal safe_to_load
signal loading_finished

@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	loading_finished.connect(_on_loading_finished)

func fade_in() -> void:
	animation_player.play("fade_in")

func circ_in() -> void:
	animation_player.play("circ_in")
#
#func set_label_text(text: String) -> void:
	#var formatted_text : String = "[wave amp=10.0 freq=2.0 connected=1]" + text + "[/wave]"
	#label.text = formatted_text

func _on_loading_finished() -> void:
	animation_player.play("circ_out")
	await animation_player.animation_finished
	queue_free()

func _on_safe_to_load() -> void:
	safe_to_load.emit()
