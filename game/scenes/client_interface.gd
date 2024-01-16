extends CanvasLayer

@onready var commongrounds_interface : MarginContainer = $CommongroundsInterface
@onready var chat : PanelContainer = $CommongroundsInterface/Chat

@onready var blur : ColorRect = $Blur
@onready var loader : ClientLoader = $ClientLoader

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
