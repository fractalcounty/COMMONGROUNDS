extends CanvasLayer

signal fade_in_finished
signal fade_out_finished
signal scene_visible
signal ng_connection_timed_out

@export_subgroup("Loading Messages")
@export var default_message : String = "[wave amp=50.0 freq=5.0 connected=1]LOADING...[/wave]"
@export_range(0, 60, 1, "suffix:s") var default_timeout : float = 20.0
@export var default_timeout_message : String = "LOADING TIMED OUT"
@export var newgrounds_message : String = "[wave amp=50.0 freq=5.0 connected=1]CONNECTING TO NEWGROUNDS...[/wave]"
@export_range(0, 60, 1, "suffix:s") var newgrounds_timeout : float = 5.0
@export var newgrounds_timeout_message : String = "NEWGROUNDS CONNECTION TIMED OUT. TRY REFRESHING?"
@export var commongrounds_message : String = "[wave amp=50.0 freq=5.0 connected=1]CONNECTING TO COMMONGROUNDS...[/wave]"
@export_range(0, 60, 1, "suffix:s") var commongrounds_timeout : float = 10.0
@export var commongrounds_timeout_message : String = "COMMONGROUNDS CONNECTION TIMED OUT."
@export var overworld_message : String = "[wave amp=50.0 freq=5.0 connected=1]LOADING OVERWORLD[/wave]"
@export_range(0, 60, 1, "suffix:s") var overworld_timeout : float = 10.0
@export var overworld_timeout_message : String = "OVERWORLD LOADING TIMED OUT. TRY REFRESHING?"

## Loading screen states
## Both of these can be set externally, i.e 'loading_screen.set_state(State.LOADING).
enum Type { DEFAULT, NEWGROUNDS, COMMONGROUNDS, OVERWORLD } ## The type of loading message displayed. Use set_type(Type)
enum State { LOADING, INACTIVE, TIMEOUT } ## The current state of the loading screen. Use set_state(State)

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var label : RichTextLabel = $LoadingContainer/RichTextLabel
@onready var timeout_timer : Timer = $TimeoutTimer

var current_type: Type = Type.DEFAULT
var current_state: State = State.LOADING

func _ready() -> void:
	timeout_timer.timeout.connect(_on_timeout)
	set_type(Type.DEFAULT)
	anim.play("RESET")

func summon() -> void:
	set_state(State.LOADING)

func banish() -> void:
	set_state(State.INACTIVE)

func set_state(new_state: State) -> void:
	current_state = new_state
	match current_state:
		State.LOADING:
			anim.play("fade_in")
		State.INACTIVE: 
			anim.play("fade_out")
		State.TIMEOUT:
			Log.error("Loading state timed out of type: " + str(current_state), self)

func set_type(new_type: Type) -> void:
	current_type = new_type
	match current_type:
		Type.DEFAULT:
			label.text = default_message
			_start_timeout_timer(default_timeout)
		Type.NEWGROUNDS:
			label.text = newgrounds_message
			_start_timeout_timer(newgrounds_timeout)
		Type.COMMONGROUNDS:
			label.text = commongrounds_message
			_start_timeout_timer(commongrounds_timeout)
		Type.OVERWORLD:
			label.text = overworld_message
			_start_timeout_timer(overworld_timeout)

func _start_timeout_timer(duration: float) -> void:
	timeout_timer.wait_time = duration
	timeout_timer.start()

func _on_timeout() -> void:
	match current_type:
		Type.DEFAULT:
			label.text = default_timeout_message
		Type.NEWGROUNDS:
			label.text = newgrounds_timeout_message
		Type.COMMONGROUNDS:
			label.text = commongrounds_timeout_message
		Type.OVERWORLD:
			label.text = overworld_timeout_message

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		fade_in_finished.emit()
	if anim_name == "fade_out":
		fade_out_finished.emit()

func on_new_scene_visible() -> void:
	scene_visible.emit()
