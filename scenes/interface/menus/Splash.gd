extends Control

@export var anim : AnimationPlayer

func _ready() -> void:
	GameManager.splash_screen_ready.emit()
	anim.play("splash")

func _on_anim_finished(anim_name: StringName) -> void:
	GameManager.splash_screen_exit.emit()
	queue_free()
	#SceneManager.load_scene(self, "main_menu")

#func fade_out_splash_screen() -> void:
	#animation_player.play("fade_out")
	#await anim.animation_finished
	#queue_free()
