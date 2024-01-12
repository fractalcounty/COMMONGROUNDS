@icon("res://resources/textures/icons/Client.svg")
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

enum LoadingState {
	INIT,
	NG_CONNECTING,
	NG_AUTHORIZING,
	CG_CONNECTING,
	CG_AUTHORIZING,
	CG_LOADING,
	CG_CONNECTED
	}

var current_loading_state : LoadingState = LoadingState.NG_CONNECTING

var scene_references := {}
var load_start_time : int
var next_scene_path : String = ""
var doing_async_load : bool = false
var on_async_scene_loaded : Callable
var success_flag : bool = false

## References to the two children of the main Client node that are already instantiated in the editor
@onready var interface_container : Node = $Interface
@onready var post_processing : CanvasLayer = $Interface/PostProcessing
@onready var loading_screen : Node = $Interface/LoadingScreen
@onready var world : CanvasLayer = $World
@onready var splash : CanvasLayer = preload(PATH.splash).instantiate()
## Client resources (local data, essentially)
@onready var _log : LogStream = LogStream.new("Client", Log.current_log_level)
@onready var data : ClientData = ClientData.new() ## Contents should be printed in logs
@onready var config : ClientConfig = $Config
@onready var newgrounds_session : NewgroundsSession = NewgroundsSession.new()

func _ready() -> void:
	newgrounds_session.newgrounds_login_url_generated.connect(_on_newgrounds_login_url_generated)
	interface_container.add_child(splash)
	Global.client = self
	_do_startup_logs()
	await splash.finished
	loading_screen.summon("LOADING...")
	change_loading_state(LoadingState.NG_CONNECTING)

func change_loading_state(new_loading_state: LoadingState) -> void:
	current_loading_state = new_loading_state
	match current_loading_state:
		LoadingState.INIT:
			pass
		LoadingState.NG_CONNECTING:
			loading_screen.update("CREATING NEWGROUNDS SESSION...")
			add_child(newgrounds_session)
			await newgrounds_session.authorizing
			change_loading_state(LoadingState.NG_AUTHORIZING)
		LoadingState.NG_AUTHORIZING:
			loading_screen.update("LOGGING IN WITH NEWGROUNDS...")
		LoadingState.CG_CONNECTING:
			loading_screen.update("CREATING COMMONGROUNDS SESSION...")
		LoadingState.CG_AUTHORIZING:
			loading_screen.update("JOINING THE COMMONGROUNDS...")
		LoadingState.CG_LOADING:
			loading_screen.update("LOADING THE COMMONGROUNDS...")
		LoadingState.CG_CONNECTED:
			_start_async_load(PATH.overworld, Callable(self, "_on_overworld_loaded"))

func _on_newgrounds_login_url_generated(url: String) -> void:
	OS.shell_open(url)
	await newgrounds_session.healthy
	change_loading_state(LoadingState.CG_CONNECTED)

func _on_overworld_loaded(loaded_scene: Node2D) -> void:
	post_processing.grain_out()
	Global.overworld = loaded_scene
	MouseManager.overworld = Global.overworld
	world.add_child(Global.overworld)
	loading_screen.banish("HAVE FUN!!!")
	Chat.start()
	await loading_screen.scene_visible
	Chat.focused = false
	Chat.line_edit.release_focus()

func _start_async_load(path: String, callback: Callable) -> void:
	next_scene_path = path
	on_async_scene_loaded = callback
	load_start_time = Time.get_ticks_msec()
	ResourceLoader.load_threaded_request(next_scene_path)
	doing_async_load = true

func _process(_delta: float) -> void:
	if doing_async_load:
		_async_load(_delta)

func _async_load(_delta: float) -> void:
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
			doing_async_load = false
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			_log.fatal("Failed to load scene: ", next_scene_path)
			next_scene_path = ""
			success_flag = false
			doing_async_load = false
	
func _do_startup_logs() -> void:
	#var data_dict : Dictionary = data.to_dict()
	#var pretty_data : String = "data: {\n\t" + str(data_dict).replace(", \"", ",\n\t\"") + "\n}"
	
	#var config_dict : Dictionary = config.to_dict()
	#var pretty_config : String = "config: {\n\t" + str(config_dict).replace(", \"", ",\n\t\"") + "\n}"
	
	#_log.debug("Starting COMMONGROUNDS client...\n" + pretty_data)
	_log.debug("Starting COMMONGROUNDS client...")
