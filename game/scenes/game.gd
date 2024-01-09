extends Node
class_name Game
## This is the script for the main scene (Game).
##
## It handles the loading and unloading of scenes.
##
## @tutorial: https://github.com/fractalcounty/ChasersWorld/blob/main/docs/structure.png

## References to the two children of the main Game node that are already instantiated in the editor
@onready var interface_container : Node = $Interface
@onready var post_processing : CanvasLayer = $Interface/PostProcessing
@onready var loading_screen : Node = $Interface/LoadingScreen
@onready var world : CanvasLayer = $World

const PATH : Dictionary = {
	"splash": "res://scenes/interface/splash/Splash.tscn",
	"ng_auth": "res://scenes/interface/NGAuth.tscn",
	"main_menu": "res://scenes/interface/menus/MainMenu.tscn",
	"main_menu_bg": "res://scenes/world/MainMenuBackground.tscn",
	"overworld": "res://scenes/world/Overworld.tscn",
	"loading_screen": "res://scenes/interface/loading_screen/LoadingScreen.tscn"
}

var scene_references := {}
var load_start_time : int
var next_scene_path : String = ""
var on_async_scene_loaded : Callable
var success_flag : bool = false
var log : LogStream = LogStream.new("Game", Log.current_log_level)

## Tracking of node status & loading and whatnot
signal main_menu_ready
signal overworld_ready
signal hide_loading_screen

func _ready() -> void:
	log.info(_startup_logs())
	set_process(false)
	_load_splash()

func _load_threaded(scene_path: String, scene_key: String, callback: Callable) -> void:
	scene_references[scene_key] = null
	_start_async_load(scene_path, callback)

func _load_splash() -> void:
	if not Global.SKIP_SPLASH:
		log.info("Preloading splash scene...")
		Global.splash = preload(PATH.splash).instantiate()
		interface_container.add_child(Global.splash)
		await Global.splash.finished
		loading_screen.set_state(loading_screen.State.LOADING)
		await loading_screen.fade_in_finished
		Global.splash.queue_free()
		_load_main_menu()
	else:
		_load_main_menu()

func _load_main_menu() -> void:
	if not Global.SKIP_MENU:
		log.info("Preloading menu scene...")
		Global.main_menu = preload(PATH.main_menu).instantiate()
		interface_container.add_child(Global.main_menu)
		await Global.main_menu.is_node_ready()
		Global.main_menu.game = self
		if Global.splash != null:
			Global.splash = null
		loading_screen.set_state(loading_screen.State.IDLE)
		await Global.main_menu.main_menu_enter
		_on_main_menu_enter()
	else:
		_load_ng_auth()

func _on_main_menu_enter() -> void:
	loading_screen.set_state(loading_screen.State.LOADING)
	await loading_screen.fade_in_finished
	_load_ng_auth()

func _load_ng_auth() -> void:
	if not Global.SKIP_NG_AUTH:
		loading_screen.set_text("CONNECTING TO NEWGROUNDS...")
		Newgrounds.initialize()
		await Newgrounds.initialized
		#loading_screen.set_text("AUTHORIZING WITH NEWGROUNDS...")
		#await Newgrounds.is_valid
		load_overworld()
	else:
		log.debug("Skipping Newgrounds authentification...")
		load_overworld()

func load_overworld() -> void:
	loading_screen.set_text("LOADING THE COMMONGROUNDS...")
	_start_async_load(PATH.overworld, Callable(self, "_on_overworld_loaded"))

func _on_overworld_loaded(loaded_scene: Node2D) -> void:
	if Global.splash != null:
		pass
		#Global.splash.queue_free()
	if not Global.SKIP_MENU:
		Global.main_menu.queue_free()
		Global.main_menu.play()
	post_processing.grain_out()
	Global.overworld = loaded_scene
	MouseManager.overworld = Global.overworld
	world.add_child(Global.overworld)
	loading_screen.set_state(loading_screen.State.IDLE)
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
				log.info("Loading scene asynchronously: ", next_scene_path)
				success_flag = true
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			var loaded_scene : Node = ResourceLoader.load_threaded_get(next_scene_path).instantiate()
			if on_async_scene_loaded and on_async_scene_loaded.is_valid():
				var load_time_in_seconds : float = (Time.get_ticks_msec() - load_start_time) / 1000.0
				log.info("[Game.gd] Successfully loaded " + next_scene_path + " asynchronously in " + str(load_time_in_seconds) + " sec.")
				on_async_scene_loaded.call(loaded_scene)
			next_scene_path = ""
			success_flag = false
			set_process(false)
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			log.fatal("Failed to load scene: ", next_scene_path)
			next_scene_path = ""
			success_flag = false
			set_process(false)

func _startup_logs() -> String:
	var arguments_used := []
	if Global.SKIP_MENU:
		arguments_used.append("SKIP_INTRO")
	if Global.SKIP_SPLASH:
		arguments_used.append("SKIP_SPLASH")
	if Global.SKIP_NG_AUTH:
		arguments_used.append("SKIP_NG_AUTH")

	return "Starting game with arguments: " + ", ".join(arguments_used) if arguments_used.size() > 0 else "Starting game with default arguments"
