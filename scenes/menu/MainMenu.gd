extends Control

func _ready() -> void:
	SceneManager.main_menu_ready.emit()

func _on_start_pressed() -> void:
	SceneManager.load_scene(self, "scene1")


func _on_exit_pressed() -> void:
	SceneManager.main_menu_instance = null
	SceneManager.main_menu_exit.emit()
	get_tree().quit()
