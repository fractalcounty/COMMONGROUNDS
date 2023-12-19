extends Node

## General launch arguments
## Todo: allow OS-level launch args
const SKIP_INTRO : bool = true

## SceneManager.gd constants
## Defines scnees loaded by the SceneManager singleton
const MAP_PATH : String = "res://scenes/_debug/Scene2.tscn"
const MAIN_MENU_PATH = preload("res://scenes/menu/MainMenu.tscn")
const SPLASH_SCREEN_PATH = preload("res://scenes/menu/Splash.tscn")
const INTERFACE_POST_PROCESSING = preload("res://scenes/menu/PostProcessing.tscn")

## SoundManager.gd constants
const UI_SOUND_BUS : String = "Interface"
const WORLD_SOUND_BUS : String = "World"

## Initialization of game
func _ready() -> void:
	GameManager.game = self
	GameManager.game_ready.emit()
	
	SoundManager.set_default_sound_bus(WORLD_SOUND_BUS)
	SoundManager.set_default_ui_sound_bus(UI_SOUND_BUS)
	
	SceneManager.load_game(SKIP_INTRO)
