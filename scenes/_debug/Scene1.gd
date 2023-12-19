extends Node3D

func _ready() -> void:
	SceneManager.world_ready.emit()
	SceneManager.world = self

func _exit_tree() -> void:
	SceneManager.world_exit.emit()
	SceneManager.world = null
