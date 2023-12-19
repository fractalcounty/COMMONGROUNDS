extends Node

const PATH_TO_PROGRESS_BAR: String = "Container/ProgressBar"

# Creating a log stream for SceneManager
var logging = LogStream.new("SceneManager", LogStream.LogLevel.INFO)

enum ThreadStatus {
	INVALID_RESOURCE = 0, # THREAD_LOAD_INVALID_RESOURCE
	IN_PROGRESS = 1, # THREAD_LOAD_IN_PROGRESS
	FAILED = 2, # THREAD_LOAD_FAILED
	LOADED = 3 # THREAD_LOAD_LOADED
}

# Virtual function for generating boot log message
func _boot_logs(skip_intro: bool) -> String:
	var log_message := "Loading game with arguments: "
	var arguments_used := []

	if skip_intro:
		arguments_used.append("skip_intro")

	if arguments_used.size() > 0:
		# Manually join the strings
		var arguments_str := ""
		for i in range(arguments_used.size()):
			arguments_str += arguments_used[i]
			if i < arguments_used.size() - 1:
				arguments_str += ", "
		log_message += arguments_str
	else:
		log_message = "Loading game with default settings"

	return log_message

func load_game(SKIP_INTRO : bool) -> void:
	logging.info(_boot_logs(SKIP_INTRO))

	if not SKIP_INTRO:
		# Instantiate and display the splash screen under the 'parent' node
		GameManager.interface_post_processing = GameManager.game.INTERFACE_POST_PROCESSING.instantiate()
		GameManager.interface.add_child(GameManager.interface_post_processing)
		# Instantiate and display the splash screen under the 'parent' node
		GameManager.splash_screen = GameManager.game.SPLASH_SCREEN_PATH.instantiate()
		GameManager.interface.add_child(GameManager.splash_screen)
		# Preparing the main menu to be displayed after the splash screen
		GameManager.main_menu = GameManager.game.MAIN_MENU_PATH.instantiate()
		GameManager.interface.add_child(GameManager.main_menu)
	else:
		load_scene()

func load_scene(kill_scene : Node = null) -> void:
	
	logging.debug("Loading scene: ", GameManager.game.MAP_PATH)

	# Request to load the scene
	if ResourceLoader.load_threaded_request(GameManager.game.MAP_PATH) != OK:
		logging.error("ResourceLoader.INVALID_PATH: ", GameManager.game.MAP_PATH)
		return

	if kill_scene:
		kill_scene.queue_free()

	while true:
		var load_progress = []
		var load_status = ResourceLoader.load_threaded_get_status(GameManager.game.MAP_PATH, load_progress)

		match load_status:
			ThreadStatus.INVALID_RESOURCE:
				logging.error("ThreadStatus.INVALID_RESOURCE: ", GameManager.game.MAP_PATH)
				return
			ThreadStatus.IN_PROGRESS:
				logging.info("ThreadStatus.IN_PROGRESS: Loading instance...", GameManager.game.MAP_PATH)
				OS.delay_msec(100)
				continue
			ThreadStatus.FAILED:
				logging.error("ThreadStatus.FAILED: ", GameManager.game.MAP_PATH)
				return
			ThreadStatus.LOADED:
				load_next_scene(GameManager.game.MAP_PATH)
				return

func load_next_scene(path: String) -> void:
	var next_scene_instance = ResourceLoader.load_threaded_get(path).instantiate()
	GameManager.game.call_deferred("add_child", next_scene_instance)
	logging.info("Next scene loaded: ", path)
