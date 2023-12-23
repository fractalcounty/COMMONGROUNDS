extends CanvasLayer

@export var MAIN_MENU_PATH : PackedScene = preload("res://scenes/interface/menus/MainMenu.tscn")
@export var SPLASH_SCREEN_PATH : PackedScene = preload("res://scenes/interface/menus/Splash.tscn")
@export var POST_PROCESSING_PATH : PackedScene = preload("res://scenes/interface/menus/PostProcessing.tscn")

@export var game : Node
@onready var main_menu : CanvasLayer = null 
@onready var splash_screen : CanvasLayer = null
@onready var post_processing : CanvasLayer = null

func load_main_menu() -> void:
	if not has_node(POST_PROCESSING_PATH.get_name()):
		post_processing = POST_PROCESSING_PATH.instantiate()
		add_child(post_processing)
		
	if not has_node(SPLASH_SCREEN_PATH.get_name()):
		splash_screen = SPLASH_SCREEN_PATH.instantiate()
		add_child(splash_screen)
		
	if not has_node(MAIN_MENU_PATH.get_name()):
		main_menu = MAIN_MENU_PATH.instantiate()
		add_child(main_menu)


func on_button_hover() -> void:
	pass
	#SoundManager.play_ui_sound(hover_sound)
	
func on_button_press() -> void:
	pass
	#SoundManager.play_ui_sound(press_sound)
	
func on_button_release() -> void:
	pass
	#SoundManager.play_ui_sound(release_sound)
