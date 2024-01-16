@icon("res://resources/textures/icons/Client.svg")
extends Node
class_name Client
## This is the script for the main user client
##
## It handles the loading and unloading of scenes.
##
## @tutorial: https://github.com/fractalcounty/ChasersWorld/blob/main/docs/structure.png

@onready var _log : LogStream = LogStream.new("Client", Global.client_log_level)
@onready var splash_screen : PackedScene = preload("res://scenes/interface/splash/SplashScreen.tscn")
var splash_screen_instance: Node = null

enum State { INIT, NG_SESSION_INVALID, NG_USER_INVALID, CG_SESSION_INVALID, OK}
var current_state: State = State.INIT
var last_state: State = State.INIT

func _ready() -> void:
	Newgrounds.session_updated.connect(_on_newgrounds_session_updated)
	_log.info("Starting COMMONGROUNDS client...")
	
	if Config.is_skip_splash():
		if Config.is_offline_mode():
			SceneLoader.load_scene("world", $WorldLayer, false)
	elif Config.is_offline_mode():
		_instantiate_splash_screen()
		await splash_screen_instance.video_finished
		SceneLoader.load_scene("world", $WorldLayer, false)
	else:
		change_state(State.NG_SESSION_INVALID)

func _instantiate_splash_screen() -> void:
	splash_screen_instance = splash_screen.instantiate()
	add_child(splash_screen_instance)

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	
	last_state = current_state
	current_state = new_state
	
	match current_state:
		State.INIT:
			_log.debug("State changed to INIT")
			change_state(State.NG_SESSION_INVALID)
		State.NG_SESSION_INVALID:
			_log.debug("State changed to NG_SESSION_INVALID")
			Newgrounds.initialize()
		State.NG_USER_INVALID:
			_log.debug("State changed to NG_USER_INVALID")
			_instantiate_splash_screen()
			await splash_screen_instance.video_finished
			await get_tree().create_timer(1.0).timeout
			OS.shell_open(Newgrounds.session.passport_url)
			Newgrounds.keepalive_timer.keepalive(1)
		State.CG_SESSION_INVALID:
			_log.debug("State changed to CG_SESSION_INVALID")
			Newgrounds.keepalive_delay = 10.0
			SceneLoader.load_scene("world", $WorldLayer, false)
		State.OK:
			pass

func _on_newgrounds_session_updated(session: NewgroundsSession):
	_log.debug("Session Updated: " + str(session))
	if session == null:
		change_state(State.NG_SESSION_INVALID)
	elif session.user == null:
		change_state(State.NG_USER_INVALID)
	else:
		change_state(State.CG_SESSION_INVALID)



