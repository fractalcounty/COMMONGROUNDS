extends Node
## This is the script for the main scene (Game).
##
## It handles the loading and unloading of scenes, game
## state management, launch parameters, and more.
##
## Once this script runs, Game will have 2 children:
## Interface: Parent of all 2D and UI related nodes, and 
## World: Parent of geometry, player, etc.
##
## Note: While 'Interface' is already a child of Game,
## the 'World' node is not. This is because 'World' is
## a scene and must be loaded by calling load_world().

# General game properties
@export var SKIP_INTRO : bool = true ## Runs load_world() instead of load_menu() upon startup

# Scene Filepaths
@export_subgroup("Scene Properties")
@export var WORLD_PATH : String = "res://scenes/world/World.tscn"

# Scene instances & signals
@onready var world : Node3D = null
@onready var interface : Control = $Interface

enum ThreadStatus {
	INVALID_RESOURCE,
	IN_PROGRESS,
	FAILED,
	LOADED
}

func _ready() -> void: ## Runs on game startup
	print(_startup_logs())
	interface.load_menu() if not SKIP_INTRO else load_world()

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
