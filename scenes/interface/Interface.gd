extends Control

@export var MAIN_MENU_PATH : PackedScene = preload("res://scenes/interface/menus/MainMenu.tscn")
@export var SPLASH_SCREEN_PATH : PackedScene = preload("res://scenes/interface/menus/Splash.tscn")
@export var INTERFACE_FX_PATH : PackedScene = preload("res://scenes/interface/menus/PostProcessing.tscn")

@export var hover_sound : AudioStream
@export var press_sound : AudioStream
@export var release_sound : AudioStream

func load_menu() -> void:
	for scene in [INTERFACE_FX_PATH, SPLASH_SCREEN_PATH, MAIN_MENU_PATH]:
		if not has_node(scene.get_name()):
			add_child(scene.instantiate())
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _exit_tree() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func on_button_hover() -> void:
	pass
	#SoundManager.play_ui_sound(hover_sound)
	
func on_button_press() -> void:
	pass
	#SoundManager.play_ui_sound(press_sound)
	
func on_button_release() -> void:
	pass
	#SoundManager.play_ui_sound(release_sound)
