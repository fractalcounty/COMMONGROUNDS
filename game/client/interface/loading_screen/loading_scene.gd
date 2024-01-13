extends Control

signal fade_in_finished
signal fade_out_finished
signal ng_connection_timed_out
signal cg_loaded(loaded_scene:Node)

signal screen_covered
signal screen_visible

var loading_status : ResourceLoader.ThreadLoadStatus
var progress : Array[float] = [0.0]
var is_loading : bool = false
var load_start_time : int
var is_loading_async: bool = false
var _path : String = "res://client/commongrounds/Commongrounds.tscn"
var _msg : String = ""

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var label : RichTextLabel = $LoadingContainer/RichTextLabel
@onready var err_label : Label = $CenterContainer/ErrorLabel
@onready var _log : LogStream = LogStream.new("LoadingScene", Log.current_log_level)

func _ready() -> void:
	anim.play("RESET")

func goto(msg: String, path: String, summon: bool = false) -> void:
	_msg = msg
	_path = path
	ResourceLoader.load_threaded_request(_path)
	if summon:
		summon(msg)
		await screen_covered
		is_loading_async = true
	else:
		is_loading_async = true

func _process(_delta: float) -> void:
	_async_load(_delta)

func _async_load(_delta: float) -> void:
	if is_loading_async:
		load_start_time = Time.get_ticks_msec()
		loading_status = ResourceLoader.load_threaded_get_status(_path, progress)
		
		var load_progress : float = progress[0] * 100
		var message: String = _msg + ": " + str(load_progress) + "%"
		_set_text(message)
		
		match loading_status:
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
				_log.info("Loading scene asynchronously: ", _path)
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
				var load_time_in_seconds : float = (Time.get_ticks_msec() - load_start_time) / 1000.0
				_log.info("Successfully loaded " + _path + " asynchronously in " + str(load_time_in_seconds) + " sec.")
				var loaded_scene : Node = ResourceLoader.load_threaded_get(_path).instantiate()
				get_parent().get_parent().add_child(loaded_scene)
				cg_loaded.emit(loaded_scene)
				_path = ""
				is_loading_async = false
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
				_log.fatal("Failed to load scene: ", _path)
				_path = ""
				is_loading_async = false

func summon(msg: String) -> void:
	_set_text(msg)
	anim.play("fade_in")

func update(msg: String) -> void:
	_set_text(msg)
	anim.play("hold")

func banish(msg: String = "") -> void:
	_set_text(msg)
	anim.play("fade_out")

func _set_text(text: String) -> void:
	var final_text : String = "[wave amp=10.0 freq=2.0 connected=1]" + text + "[/wave]"
	label.text = final_text

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		is_loading = true
		fade_in_finished.emit()
		anim.play("hold")
	if anim_name == "fade_out":
		is_loading = false
		fade_out_finished.emit()
		anim.play("RESET")

func on_screen_covered() -> void:
	screen_covered.emit()

func on_screen_visible() -> void:
	screen_visible.emit()
