extends Node
class_name Client
## This is the script for the main user client
##
## It handles the loading and unloading of scenes.
##
## @tutorial: https://github.com/fractalcounty/ChasersWorld/blob/main/docs/structure.png

## Tracking of node status & loading and whatnot
signal main_menu_ready
signal overworld_ready
signal hide_loading_screen

const PATH : Dictionary = {
	"splash": "res://scenes/interface/splash/Splash.tscn",
	"overworld": "res://scenes/world/Overworld.tscn",
	"loading_screen": "res://scenes/interface/loading_screen/LoadingScreen.tscn"
}

var scene_references := {}
var load_start_time : int
var next_scene_path : String = ""
var on_async_scene_loaded : Callable
var success_flag : bool = false
var _log : LogStream = LogStream.new("Client", Log.current_log_level)

## References to the two children of the main Client node that are already instantiated in the editor
@onready var interface_container : Node = $Interface
@onready var post_processing : CanvasLayer = $Interface/PostProcessing
@onready var loading_screen : Node = $Interface/LoadingScreen
@onready var world : CanvasLayer = $World
## Client resources (local data, essentially)
@onready var data : ClientData = ClientData.new() ## Contents should be printed in logs
@onready var settings : ClientConfig = ClientConfig.new()

func _ready() -> void:
	_do_startup_logs()
	set_process(false)
	_load_splash()

func _load_threaded(scene_path: String, scene_key: String, callback: Callable) -> void:
	scene_references[scene_key] = null
	_start_async_load(scene_path, callback)

func _load_splash() -> void:
	_log.info("Preloading splash scene...")
	
	Global.splash = preload(PATH.splash).instantiate()
	interface_container.add_child(Global.splash)
	await Global.splash.finished
	
	loading_screen.set_state(loading_screen.State.LOADING)
	await loading_screen.fade_in_finished
	
	Global.splash.queue_free()
	
	_load_ng_auth()

func _load_ng_auth() -> void:
	loading_screen.set_text("CONNECTING TO NEWGROUNDS...")
	await Newgrounds.logging_in
	
	loading_screen.set_text("LOGGING IN WITH NEWGROUNDS...")

	loading_screen.set_text("LOADING THE COMMONGROUNDS...")
	_start_async_load(PATH.overworld, Callable(self, "_on_overworld_loaded"))

func _on_overworld_loaded(loaded_scene: Node2D) -> void:
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

func _process(_delta: float) -> void:
	var status : ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(next_scene_path)
	match status:
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
			if not success_flag:
				_log.info("Loading scene asynchronously: ", next_scene_path)
				success_flag = true
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			var loaded_scene : Node = ResourceLoader.load_threaded_get(next_scene_path).instantiate()
			if on_async_scene_loaded and on_async_scene_loaded.is_valid():
				var load_time_in_seconds : float = (Time.get_ticks_msec() - load_start_time) / 1000.0
				_log.info("Successfully loaded " + next_scene_path + " asynchronously in " + str(load_time_in_seconds) + " sec.")
				on_async_scene_loaded.call(loaded_scene)
			next_scene_path = ""
			success_flag = false
			set_process(false)
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			_log.fatal("Failed to load scene: ", next_scene_path)
			next_scene_path = ""
			success_flag = false
			set_process(false)
	
func _do_startup_logs() -> void:
	var data_dict : Dictionary = data.to_dict()
	var pretty_data : String = "data: {\n\t" + str(data_dict).replace(", \"", ",\n\t\"") + "\n}"
	
	var settings_dict : Dictionary = settings.to_dict()
	var pretty_settings : String = "settings: {\n\t" + str(settings_dict).replace(", \"", ",\n\t\"") + "\n}"
	
	_log.debug("Starting COMMONGROUNDS client...\n" + pretty_data + "\n" + pretty_settings)
