extends Node

@export var splash_scene : Control
@export var interface : Control

var path_to_progress_bar: String = "Container/ProgressBar"

signal mainmenu_ready

enum GameState {
	MENU = 0,
	WORLD = 1,
}

# Creating a log stream for SceneManager
var logging = LogStream.new("Game", LogStream.LogLevel.DEBUG)

func _ready() -> void:
	logging.info("Ready...")
	SceneManager.game = self
	SceneManager.set_configuration({
		"scenes": {
			"scene1": "res://scenes/_debug/Scene1.tscn",
			"scene2": "res://scenes/_debug/Scene2.tscn",
			"main_menu": "res://scenes/menu/MainMenu.tscn"
		},
		"path_to_progress_bar": "Container/ProgressBar",
		"loading_screen": "res://scenes/menu/LoadingScreen.tscn"
	})
	SceneManager.load_game(interface)
