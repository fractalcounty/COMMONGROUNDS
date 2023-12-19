extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.world = self
	GameManager.world_ready.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _exit_tree() -> void:
	GameManager.world_exit.emit()
