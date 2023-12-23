extends CanvasLayer

@onready var menu_noise : ColorRect = $MenuNoise

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_map_ready() -> void:
	menu_noise.hide()

func _on_map_exit() -> void:
	menu_noise.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
