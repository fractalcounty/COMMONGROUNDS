extends CanvasLayer

signal fade_in_finished
signal fade_out_finished
signal scene_visible
signal ng_connection_timed_out
signal loading()

## Loading screen states
## Both of these can be set externally, i.e 'loading_screen.set_state(State.LOADING).
enum State { LOADING, IDLE, ERROR } ## The current state of the loading screen. Use set_state(State)

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var label : RichTextLabel = $LoadingContainer/RichTextLabel
@onready var err_label : Label = $CenterContainer/ErrorLabel

var current_state: State = State.LOADING
var previous_state : State = State.IDLE

func set_text(text: String) -> void:
	var final_text : String = "[wave amp=30.0 freq=3.0 connected=1]" + text + "[/wave]"
	label.text = final_text

func _ready() -> void:
	Global.error_shown.connect(_on_error_shown)
	Global.error_freed.connect(_on_error_freed)
	Global.loading_screen = self
	anim.play("RESET")

func _on_error_shown(message:String) -> void:
	previous_state = current_state
	err_label.text = message
	set_state(State.ERROR)

func _on_error_freed(_message:String) -> void:
	if previous_state == State.LOADING:
		set_state(State.LOADING)
	elif previous_state == State.IDLE:
		set_state(State.IDLE)

func set_state(new_state: State) -> void:
	if Global.error_blocking and new_state != State.ERROR:
		Log.error("Loading screen unable to transition to state '" + str(new_state) + "' due to unresolved fatal error.")
		return
	match [previous_state, new_state]:
		[State.IDLE, State.ERROR]:
			anim.play("err_fade_in")
		[State.ERROR, State.IDLE]:
			anim.play("err_fade_out")
		[State.LOADING, State.ERROR]:
			anim.play("err_trans_in")
		[State.ERROR, State.LOADING]:
			anim.play("err_trans_out")
		[State.IDLE, State.LOADING]:
			anim.play("fade_in")
		[State.LOADING, State.IDLE]:
			anim.play("fade_out")
	current_state = new_state
	previous_state = new_state

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		fade_in_finished.emit()
	if anim_name == "fade_out":
		fade_out_finished.emit()

func on_new_scene_visible() -> void:
	scene_visible.emit()
