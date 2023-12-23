extends Control

@export var anim : AnimationPlayer

func _ready() -> void:
	anim.play("splash")

func _on_anim_finished(anim_name: StringName) -> void:
	queue_free()

#func fade_out_splash_screen() -> void:
	#animation_player.play("fade_out")
	#await anim.animation_finished
	#queue_free()
