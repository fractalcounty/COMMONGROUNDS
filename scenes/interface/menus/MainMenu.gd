extends Control

func _ready() -> void:
	GameManager.main_menu_ready.emit()

func _on_start_pressed() -> void:
	SceneManager.load_scene(self)


func _on_exit_pressed() -> void:
	GameManager.main_menu_exit.emit()
	get_tree().quit()

func _on_start_mouse_entered() -> void:
	GameManager.interface.on_button_hover()

func _on_exit_mouse_entered() -> void:
	GameManager.interface.on_button_hover()


func _on_start_button_up() -> void:
	GameManager.interface.on_button_release()


func _on_start_button_down() -> void:
	GameManager.interface.on_button_press()


func _on_exit_button_up() -> void:
	GameManager.interface.on_button_release()


func _on_exit_button_down() -> void:
	GameManager.interface.on_button_press()
