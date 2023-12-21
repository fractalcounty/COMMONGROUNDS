extends Node

## General game properties
# TODO: Change these from exports to executable launch arguments
@export var SKIP_INTRO : bool = true

#region Autoload Properties (res://src)
@export_category("Autoload Properties")

@export_subgroup("SceneManager")
@export var MAP_PATH : String = "res://scenes/world/map/Map.tscn"
@export var MAIN_MENU_PATH = preload("res://scenes/interface/menus/MainMenu.tscn")
@export var SPLASH_SCREEN_PATH = preload("res://scenes/interface/menus/Splash.tscn")
@export var INTERFACE_POST_PROCESSING = preload("res://scenes/interface/menus/PostProcessing.tscn")

@export_subgroup("SoundManager")
@export var SOUND_BUS : String = "Sound"
@export var INTERFACE_SOUND_BUS : String = "Interface"
@export var MUSIC_BUS : String = "Music"
#endregion

## Initialization of game
func _ready() -> void:
	GameManager.game = self
	GameManager.game_ready.emit()
	
	SceneManager.load_game(SKIP_INTRO)
	
	SoundManager.set_default_sound_bus(SOUND_BUS)
	SoundManager.set_default_music_bus(MUSIC_BUS)
	SoundManager.set_default_ui_sound_bus(INTERFACE_SOUND_BUS)
