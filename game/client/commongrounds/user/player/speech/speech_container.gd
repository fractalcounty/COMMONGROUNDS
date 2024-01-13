extends PanelContainer

@onready var label : RichTextLabel = $SpeechLabel
@onready var anim : AnimationPlayer = $SpeechLabel/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pivot_offset = size / 2
	anim.play('fade_in')
	await anim.animation_finished
	await get_tree().create_timer(5.0).timeout
	anim.play('fade_out')
	await anim.animation_finished
	queue_free()
