extends Node
class_name Game
## This is the script for the main scene (Game).
##
## It handles the loading and unloading of scenes, game
## state management, launch parameters, and more.
##
## @tutorial: https://github.com/fractalcounty/ChasersWorld/blob/main/docs/structure.png

## General launch parameters
@export var SKIP_SPLASH : bool = false ## Skips the splash screen
@export var SKIP_MENU : bool = false ## Skips the menu

## References to the two children of the main Game node that are already instantiated in the editor
@onready var interface_container : Node = $Interface
@onready var post_processing : CanvasLayer = $Interface/PostProcessing
@onready var loading_screen : Node = $Interface/LoadingScreen
@onready var world : CanvasLayer = $World

const PATH : Dictionary = {
	"splash": "res://scenes/interface/splash/Splash.tscn",
	"main_menu": "res://scenes/interface/menus/MainMenu.tscn",
	"main_menu_bg": "res://scenes/world/MainMenuBackground.tscn",
	"overworld": "res://scenes/world/Overworld.tscn",
	"loading_screen": "res://scenes/interface/loading_screen/LoadingScreen.tscn"
}

## References to instances of the scenes above
## These are null until they are actually instantiated
@onready var splash : Node = null
@onready var main_menu : Node = null
@onready var overworld : Node2D = null 

var scene_references := {}
var load_start_time : int
var next_scene_path : String = ""
var on_async_scene_loaded : Callable
var success_flag : bool = false

## Tracking of node status & loading and whatnot
signal main_menu_ready
signal overworld_ready
signal hide_loading_screen

func _ready() -> void:
	Log.debug(_startup_logs(), self)
	
	NG.request_completed.connect(_on_request_completed)
	#Log.debug("Requesting NG.io component 'Gateway.getVersion' with parameters: {}", self)
	#NG.request("Gateway.getVersion", {}, Callable(self, "_on_version_get"))
	NG.request("Gateway.getVersion", {})
	
	set_process(false)
	_load_splash()

func _on_version_get(response_data: Dictionary) -> void:
	Log.debug("Version: " + str(response_data), self)

func _on_request_completed(response_data: Dictionary) -> void:
	Log.debug("Response Data: " + str(response_data), self)

func _input(event: InputEvent) -> void:
	Input

func _load_threaded(scene_path: String, scene_key: String, callback: Callable) -> void:
	scene_references[scene_key] = null
	_start_async_load(scene_path, callback)

func _load_splash() -> void:
	if not SKIP_SPLASH:
		splash = preload(PATH.splash).instantiate()
		interface_container.add_child(splash)
		await splash.finished
		loading_screen.fade_in()
		await loading_screen.fade_in_finished
		splash.queue_free()
		_load_main_menu()
	else:
		_load_main_menu()
	
func _load_main_menu() -> void:
	if not SKIP_MENU:
		main_menu = preload(PATH.main_menu).instantiate()
		interface_container.add_child(main_menu)
		await main_menu.is_node_ready()
		main_menu.game = self
		if splash != null:
			splash = null
		loading_screen.fade_out()
		await main_menu.main_menu_enter
		_on_main_menu_enter()
	else:
		load_overworld()

func _on_main_menu_enter() -> void:
	loading_screen.fade_in()
	await loading_screen.fade_in_finished
	load_overworld()

func load_overworld() -> void:
	_start_async_load(PATH.overworld, Callable(self, "_on_overworld_loaded"))

func _on_overworld_loaded(loaded_scene: Node2D) -> void:
	if splash != null:
		splash.queue_free()
	if not SKIP_MENU:
		main_menu.queue_free()
		main_menu.play()
	post_processing.grain_out()
	overworld = loaded_scene
	MouseManager.overworld = overworld
	world.add_child(overworld)
	loading_screen.fade_out()
	Chat.start()
	await loading_screen.scene_visible
	Chat.focused = false
	Chat.line_edit.release_focus()

func _start_async_load(path: String, callback: Callable) -> void:
	next_scene_path = path
	on_async_scene_loaded = callback
	load_start_time = Time.get_ticks_msec()
	ResourceLoader.load_threaded_request(next_scene_path)
	set_process(true)

func _process(delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(next_scene_path)
	match status:
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			if not success_flag:
				print("[Game.gd] Loading scene asynchronously: ", next_scene_path)
				success_flag = true
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			var loaded_scene : Node = ResourceLoader.load_threaded_get(next_scene_path).instantiate()
			if on_async_scene_loaded and on_async_scene_loaded.is_valid():
				var load_time_in_seconds : float = (Time.get_ticks_msec() - load_start_time) / 1000.0
				print("[Game.gd] Successfully loaded " + next_scene_path + " asynchronously in " + str(load_time_in_seconds) + " sec.")
				on_async_scene_loaded.call(loaded_scene)
			next_scene_path = ""
			success_flag = false
			set_process(false)
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			push_error("Failed to load scene: ", next_scene_path)
			next_scene_path = ""
			success_flag = false
			set_process(false)

func _startup_logs() -> String:
	var arguments_used := []
	if SKIP_MENU:
		arguments_used.append("SKIP_INTRO")
	if SKIP_SPLASH:
		arguments_used.append("SKIP_SPLASH")

	return "Starting game with arguments: " + ", ".join(arguments_used) if arguments_used.size() > 0 else "[Game.gd] Starting game with default settings"
