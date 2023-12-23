extends Node
## This is the script for the main scene (Game).
##
## It handles the loading and unloading of scenes, game
## state management, launch parameters, and more.
##
## @tutorial: https://github.com/fractalcounty/ChasersWorld/blob/main/docs/structure.png

## General launch parameters
@export var SKIP_INTRO : bool = true ## Skips the splash screen and main menu by just calling load_world()
@export var WORLD_PATH : String = "res://scenes/world/World.tscn" ## Scene loaded by load_world()
## References to instanced scenes
@onready var world : Node3D = null ## Only defined when World.tscn is instantiated in the scene tree
@onready var interface : CanvasLayer = $Interface ## Already a child of Game before startup

enum ThreadStatus {
	INVALID_RESOURCE,
	IN_PROGRESS,
	FAILED,
	LOADED
}

func _ready() -> void:
	print(_startup_logs())
	interface.load_main_menu() if not SKIP_INTRO else load_world()

func load_world(current_scene : Node = null) -> void:
	print("[Game.gd] Loading world scene: ", WORLD_PATH)
	
	if ResourceLoader.load_threaded_request(WORLD_PATH) != OK:
		push_error("[Game.gd] Error loading world scene at: ", WORLD_PATH)
		return

	if current_scene: ## Nodes passed to this function will be deleted
		current_scene.queue_free()

	var load_status = ThreadStatus.INVALID_RESOURCE
	while load_status != ThreadStatus.LOADED:
		var load_progress = []
		load_status = ResourceLoader.load_threaded_get_status(WORLD_PATH, load_progress)
		match load_status:
			ThreadStatus.INVALID_RESOURCE:
				push_error("[Game.gd] ThreadStatus.INVALID_RESOURCE: Failed to load ", WORLD_PATH)
				return
			ThreadStatus.IN_PROGRESS:
				OS.delay_msec(100)
			ThreadStatus.FAILED:
				push_error("[Game.gd] ThreadStatus.FAILED: Failed to load ", WORLD_PATH)
				return
			ThreadStatus.LOADED:
				_on_world_loaded(WORLD_PATH)

func _on_world_loaded(path: String) -> void:
	world = ResourceLoader.load_threaded_get(path).instantiate()
	call_deferred("add_child", world)
	print("[Game.gd] World scene successfully loaded!")

func _startup_logs() -> String:
	var arguments_used := []
	if SKIP_INTRO:
		arguments_used.append("SKIP_INTRO")

	return "[Game.gd] Starting game with arguments: " + ", ".join(arguments_used) if arguments_used.size() > 0 else "[Game.gd] Starting game with default settings"
