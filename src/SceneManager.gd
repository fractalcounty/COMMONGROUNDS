extends Node

var scenes: Dictionary = {}
var interface_parent: Node
var path_to_progress_bar: String = "Container/ProgressBar"
var post_processing: Resource = preload("res://scenes/menu/PostProcessing.tscn")

var main_menu: Resource = preload("res://scenes/menu/MainMenu.tscn")
var main_menu_instance : Node = null
signal main_menu_ready
signal main_menu_exit

var splash_screen: Resource = preload("res://scenes/menu/Splash.tscn")
var splash_screen_instance: Node = null
signal splash_screen_ready
signal splash_screen_exit

var loading_screen: Resource = preload("res://scenes/menu/LoadingScreen.tscn")
var loading_screen_instance: Node = null
signal loading_screen_ready
signal loading_screen_exit

var world: Node = null
signal world_ready
signal world_exit

var game : Node = null

# Creating a log stream for SceneManager
var logging = LogStream.new("SceneManager", LogStream.LogLevel.INFO)

enum ThreadStatus {
	INVALID_RESOURCE = 0, # THREAD_LOAD_INVALID_RESOURCE
	IN_PROGRESS = 1, # THREAD_LOAD_IN_PROGRESS
	FAILED = 2, # THREAD_LOAD_FAILED
	LOADED = 3 # THREAD_LOAD_LOADED
}

func load_game(parent: Node) -> void:
	if parent == null:
		logging.error("Parent node is null.")
		return

	logging.info("Loading game...")

	# Store the parent node
	interface_parent = parent

	# Instantiate and display the splash screen under the 'parent' node
	var post_processing_instance: Node = post_processing.instantiate()
	interface_parent.add_child(post_processing_instance)

	# Instantiate and display the splash screen under the 'parent' node
	splash_screen_instance = splash_screen.instantiate()
	interface_parent.add_child(splash_screen_instance)

	# Preparing the main menu to be displayed after the splash screen
	# This will instantiate the main menu but it won't be visible yet
	main_menu_instance = main_menu.instantiate()
	interface_parent.add_child(main_menu_instance)

func set_configuration(config: Dictionary) -> void:
	if config.has("scenes"):
		scenes = config["scenes"]

	if config.has("path_to_progress_bar"):
		path_to_progress_bar = config["path_to_progress_bar"]

	if config.has("loading_screen"):
		loading_screen = load(config["loading_screen"])
	
	logging.debug("Configuration set: ", config)

func load_scene(current_scene: Node, next_scene: String) -> void:
	
	logging.debug("Loading scene: ", next_scene)
	
	loading_screen_instance = initialize_loading_screen()
	if loading_screen_instance == null:
		logging.error("Failed to initialize loading screen.")
		return

	var path: String = find_scene_path(next_scene)

	# Request to load the scene
	if ResourceLoader.load_threaded_request(path) != OK:
		logging.error("ResourceLoader.INVALID_PATH: ", path)
		return

	current_scene.queue_free()

	while true:
		var load_progress = []
		var load_status = ResourceLoader.load_threaded_get_status(path, load_progress)

		match load_status:
			ThreadStatus.INVALID_RESOURCE:
				logging.error("ThreadStatus.INVALID_RESOURCE: ", path)
				return
			ThreadStatus.IN_PROGRESS:
				update_progress_bar(loading_screen_instance, path_to_progress_bar, load_progress[0])
				logging.info("ThreadStatus.IN_PROGRESS: Loading instance...", path)
				OS.delay_msec(100)
				continue
			ThreadStatus.FAILED:
				logging.error("ThreadStatus.FAILED: ", path)
				return
			ThreadStatus.LOADED:
				load_next_scene(path, loading_screen_instance)
				return

func initialize_loading_screen() -> Node:
	loading_screen_instance = loading_screen.instantiate()
	logging.debug("Initializing loading screen.")

	if interface_parent != null:
		interface_parent.add_child(loading_screen_instance)
	else:
		get_tree().get_root().add_child(loading_screen_instance)

	return loading_screen_instance

func find_scene_path(next_scene: String) -> String:
	# Find path to the scene file
	var path: String = scenes[next_scene] if scenes.has(next_scene) else next_scene
	logging.debug("Finding scene path: ", path)

	# Validate path
	if not ResourceLoader.exists(path):
		logging.error("ResourceLoader.INVALID_PATH: ", path)
		return ""

	return path

func update_progress_bar(loading_screen_instance: Node, path_to_progress_bar: String, load_progress: int) -> void:
	if path_to_progress_bar == "":
		return

	var progress_bar := loading_screen_instance.get_node(path_to_progress_bar)

	if progress_bar == null:
		logging.error("Error updating progress bar at ", path_to_progress_bar)
	else:
		progress_bar.value = load_progress

func load_next_scene(path: String, loading_screen_instance: Node) -> void:
	var next_scene_instance = ResourceLoader.load_threaded_get(path).instantiate()
	game.call_deferred("add_child", next_scene_instance)
	logging.info("Next scene loaded: ", path)
