extends Node

@onready var game : Node = null
signal game_ready
signal game_exit

@onready var interface : Control = null
signal interface_ready
signal interface_exit

@onready var world : Node3D = null
signal world_ready
signal world_exit

@onready var map : Node3D = null
signal map_ready
signal map_exit

@onready var splash_screen : Node = null
signal splash_screen_ready
signal splash_screen_exit

@onready var main_menu : Node = null
signal main_menu_ready
signal main_menu_exit

@onready var interface_post_processing : Node = null

var logging : LogStream = LogStream.new("GameManager", LogStream.LogLevel.DEBUG)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	logging.debug("Game manager initialized")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
