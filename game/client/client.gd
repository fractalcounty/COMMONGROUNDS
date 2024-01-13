@icon("res://resources/textures/icons/Client.svg")
extends Node
class_name Client
## This is the script for the main user client
##
## It handles the loading and unloading of scenes.
##
## @tutorial: https://github.com/fractalcounty/ChasersWorld/blob/main/docs/structure.png

const WORLD_PATH : String = "res://world/World.tscn"

enum State {
	NG_CONNECTING,
	NG_AUTHORIZING,
	CG_CONNECTING,
	CG_AUTHORIZING,
	CG_LOADING,
	CG_CONNECTED
	}

var current_state : State = State.NG_CONNECTING
var load_start_time : int
var next_scene_path : String = ""
var doing_async_load : bool = false
var on_async_scene_loaded : Callable
var success_flag : bool = false

@onready var world : Node2D = null

@onready var interface : CanvasLayer = $ClientInterface
@onready var chat : Control = $ClientInterface/Chat
@onready var splash : Control = $ClientInterface/SplashScreen
@onready var post_processing : Control = $ClientInterface/PostProcessing
@onready var loading_scene : Control = $ClientInterface/LoadingScene

@onready var _log : LogStream = LogStream.new("Client", Log.current_log_level)
@onready var data : ClientData = ClientData.new() ## Contents should be printed in logs
@onready var config : ClientConfig = $Config
@onready var newgrounds_session : NewgroundsSession = NewgroundsSession.new()

func _ready() -> void:
	newgrounds_session.newgrounds_login_url_generated.connect(_on_newgrounds_login_url_generated)
	_do_startup_logs()
	loading_scene.summon("LOADING...")
	change_state(State.NG_CONNECTING)

func change_state(new_state: State) -> void:
	current_state = new_state
	match current_state:
		State.NG_CONNECTING:
			loading_scene.update("CREATING NEWGROUNDS SESSION...")
			add_child(newgrounds_session)
			await newgrounds_session.authorizing
			change_state(State.NG_AUTHORIZING)
		State.NG_AUTHORIZING:
			loading_scene.update("LOGGING IN WITH NEWGROUNDS...")
		State.CG_CONNECTING:
			loading_scene.update("CREATING COMMONGROUNDS SESSION...")
		State.CG_AUTHORIZING:
			loading_scene.update("JOINING THE COMMONGROUNDS...")
		State.CG_LOADING:
			loading_scene.goto("LOADING THE COMMONGROUNDS...", WORLD_PATH, false)
		State.CG_CONNECTED:
			_log.info("Connected to COMMONGROUNDS.")

func _on_newgrounds_login_url_generated(url: String) -> void:
	OS.shell_open(url)
	await newgrounds_session.healthy
	change_state(State.CG_LOADING)

func _on_overworld_loaded(loaded_scene: Node2D) -> void:
	MouseManager.world = world
	loading_scene.banish("HAVE FUN!!!")
	await loading_scene.scene_visible
	
func _do_startup_logs() -> void:
	_log.debug("Starting COMMONGROUNDS client...")
