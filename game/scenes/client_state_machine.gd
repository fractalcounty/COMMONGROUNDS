extends FiniteStateMachine
class_name ClientStateMachine

@export var log_level: LogStream.LogLevel = LogStream.LogLevel.INFO
@onready var _log : LogStream = LogStream.new("ClientStateMachine", log_level)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state_changed.connect(_on_state_changed)

func _on_state_changed(previous_state: StateMachineState, current_state: StateMachineState) -> void:
	_log.debug("Changed from: " + str(previous_state) + " -> " + str(current_state))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
