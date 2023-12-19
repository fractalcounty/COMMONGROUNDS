extends Control

@export var hover_sound : AudioStream
@export var press_sound : AudioStream
@export var release_sound : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.interface = self
	GameManager.interface_ready.emit()

func _exit_tree() -> void:
	GameManager.interface_exit.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func on_button_hover() -> void:
	SoundManager.play_ui_sound(hover_sound)
	
func on_button_press() -> void:
	SoundManager.play_ui_sound(press_sound)
	
func on_button_release() -> void:
	SoundManager.play_ui_sound(release_sound)
