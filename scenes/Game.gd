extends Node
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
@onready var pause_menu : PopupMenu = $Interface/PauseMenu
@onready var loading_screen : Node = $Interface/LoadingScreen
@onready var world_container : Node3D = $World
#@onready var world_subviewport : SubViewport = $WorldContainer/WorldSubviewport

const PATH : Dictionary = {
	"splash": "res://scenes/interface/splash/Splash.tscn",
	"main_menu": "res://scenes/interface/menus/MainMenu.tscn",
	"main_menu_bg": "res://scenes/world/MainMenuBackground.tscn",
	"overworld": "res://scenes/world/Overworld.tscn",
	"loading_screen": "res://scenes/interface/loading_screen/LoadingScreen.tscn"
}

## References to instances of the scenes above
## These are null until they are actually instantiated
@onready var splash : Node = null ## Animation of Godot logo and publisher that first plays when game starts
@onready var main_menu : Node = null  ## 2D Main menu that occurs after the splash sequence. Child of the InterfaceContainer
@onready var main_menu_bg : Node = null ## The 3D background of the previously mentioned main menu scene. Child of the WorldSubviewport.
@onready var overworld : Node = null ## The 3D gameworld that is loaded as a child of the WorldSubviewport when the player presses play in the main menu

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
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print(_startup_logs())
	
	set_process(false)
	_load_splash()

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
		_start_async_load(PATH.main_menu_bg, Callable(self, "_on_main_menu_bg_loaded")) # Ensure this is the correct path
	else:
		load_overworld()

func _on_main_menu_bg_loaded(loaded_scene: Node3D) -> void:
	# Ensure loaded_scene is indeed a Node3D
	if loaded_scene is Node3D:
		main_menu_bg = loaded_scene
		world_container.add_child(main_menu_bg)
		if splash != null:
			splash = null
		loading_screen.fade_out()
		await main_menu.main_menu_enter
		_on_main_menu_enter()
	else:
		push_error("Loaded scene is not a Node3D.")

func _on_main_menu_enter() -> void:
	loading_screen.fade_in()
	await loading_screen.fade_in_finished
	load_overworld()

func load_overworld() -> void:
	_start_async_load(PATH.overworld, Callable(self, "_on_overworld_loaded"))

func _on_overworld_loaded(loaded_scene: Node3D) -> void:
	if splash != null:
		splash.queue_free()
	if not SKIP_MENU:
		main_menu.queue_free()
		main_menu_bg.queue_free()
		main_menu.play()
	post_processing.grain_out()
	overworld = loaded_scene
	world_container.add_child(overworld)
	loading_screen.fade_out()

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

	return "[Game.gd] Starting game with arguments: " + ", ".join(arguments_used) if arguments_used.size() > 0 else "[Game.gd] Starting game with default settings"
