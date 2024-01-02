extends CanvasLayer

@onready var mouse : Node2D = $Mouse
@onready var debug_container : VBoxContainer = $DebugContainer
@onready var debug_label_1 : Label = $DebugContainer/Label1
@onready var debug_label_2 : Label = $DebugContainer/Label2
@onready var debug_label_3 : Label = $DebugContainer/Label3
@onready var debug_offset : Vector2 = Vector2(0, 50)

var overworld : Node2D

func _ready() -> void:
	debug_container.hide()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("action_debug"):
		debug_container.show()
	#if Input.is_action_pressed("debug_extend") and Input.is_action_pressed("ui_debug"):
		#print("extend")
		#get_viewport().set_debug_draw(Viewport.DEBUG_DRAW_WIREFRAME)
	if Input.is_action_just_released("action_debug"):
		debug_container.hide()
	if event is InputEventMouseMotion:
		debug_label_1.text = "viewport: " + str(event.position)

func _process(delta: float) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_HIDDEN:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	if overworld != null:
		var overworld_pos : Vector2i = Vector2i(overworld.get_local_mouse_position())
		debug_label_2.text = "overworld: " + str(overworld_pos)
	
	var mouse_position : Vector2 = get_viewport().get_mouse_position()
	#mouse.position = mouse_position
	mouse.position = mouse_position
	
	if Input.is_action_pressed("action_debug"):
		_debug_follow()

func _debug_follow() -> void:
	debug_container.position = (mouse.position + debug_offset) - (debug_container.size / 2)

func _debug_hide() -> void:
	pass
