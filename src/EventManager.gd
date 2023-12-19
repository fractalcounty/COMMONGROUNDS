extends Node

var logging = LogStream.new("EventManager", LogStream.LogLevel.DEBUG)

signal mainmenu_ready

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	logging.debug("Event manager initialized")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
