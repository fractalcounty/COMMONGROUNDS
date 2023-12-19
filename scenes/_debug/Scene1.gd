extends Node3D

func _ready() -> void:
	GameManager.map_ready.emit()
	GameManager.map = self

func _exit_tree() -> void:
	GameManager.map_exit.emit()
