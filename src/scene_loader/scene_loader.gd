extends Node

signal ng_connection_timed_out
signal loaded(loaded_scene:Node)

signal screen_covered
signal screen_visible

const LOADING_SCREEN: PackedScene  = preload("res://src/scene_loader/loading_screen/loading_screen.tscn")

const SCENES: Dictionary = {
	"world": "res://assets/world/world.tscn"
}

var progress : Array[float] = [0.0]
var load_start_time : int

@onready var _log : LogStream = LogStream.new("SceneLoader", Log.current_log_level)

enum ThreadLoadStatus { THREAD_LOAD_INVALID_RESOURCE = 0, THREAD_LOAD_IN_PROGRESS = 1, THREAD_LOAD_FAILED = 2, THREAD_LOAD_LOADED = 3 }

## Loads a scene asynchronously and replaces the current scene with it.
##
## Arguments:
## - current_scene: The current scene to be replaced.
## - next_scene: The path to the scene to be loaded.
##
## Returns: None
func load_scene(scene: String, parent: Node, do_circ_in: bool = true) -> void:
	var loading_screen_instance: Node = _initialize_loading_screen()
	await loading_screen_instance.ready
	if do_circ_in:
		loading_screen_instance.circ_in()
	else:
		loading_screen_instance.fade_in()
	var path: String = _find_scene_path(scene)
	
	# Load scene
	if ResourceLoader.load_threaded_request(path) != OK:
		_log.err("Scene %s does not exist." % path)
		return
	
	_log.info("Loading the Commongrounds asynchronously...")
	var load_start_time: int = Time.get_ticks_msec()
	
	# Wait for loading screen to be ready
	await loading_screen_instance.safe_to_load
	
	while true:
		var load_progress = []
		var load_status = ResourceLoader.load_threaded_get_status(path, load_progress)

		match load_status:
			ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
				printerr("Can not load the resource.")
				return
			ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
				_log.debug("Progress: " + str(load_progress[0] * 100) + "^%")
				return
			ThreadLoadStatus.THREAD_LOAD_FAILED:
				printerr("Loading failed.")
				return
			ThreadLoadStatus.THREAD_LOAD_LOADED:
				_load_next_scene(path, parent, loading_screen_instance, load_start_time)
				return

func _load_next_scene(path: String, parent: Node, loading_screen_instance: Node, load_start_time: int) -> void:
	var next_scene_instance = ResourceLoader.load_threaded_get(path).instantiate()
	parent.call_deferred("add_child", next_scene_instance)
	var load_time_in_seconds : float = (Time.get_ticks_msec() - load_start_time) / 1000.0
	_log.info("Successfully loaded " + path + " asynchronously in " + str(load_time_in_seconds) + " sec.")
	loading_screen_instance.loading_finished.emit()
	
func _initialize_loading_screen() -> Node:
	var loading_screen_instance: Node = LOADING_SCREEN.instantiate()
	get_tree().get_root().call_deferred("add_child", loading_screen_instance)

	return loading_screen_instance

func _find_scene_path(scene: String) -> String:
	# Find path to the scene file
	var path: String = SCENES[scene] if SCENES.has(scene) else scene

	# Validate path
	if not ResourceLoader.exists(path):
		printerr("Scene %s does not exist." % path)
		return ""

	return path
