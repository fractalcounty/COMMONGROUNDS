extends Sprite2D

var speed : float = 450.0
var shake : float = 0.0

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	if EventManager.player != null:
		var direction := (EventManager.player.global_position - global_position).normalized()
		global_position += direction * speed * delta
		look_at(EventManager.player.global_position)

func do_shake() -> void:
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_method(EventManager.camera.set_shake, 20, 0, 0.4)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
