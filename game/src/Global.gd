extends Node
## Main global autoload for Commongrounds
##
## Contains launch parameters, references to key
## objects and instances, debugging options, and 
## global variables that need to be accessible 

signal error_shown(message:String)
signal error_freed(message:String)
var error_blocking : bool = false

## Launch parameter defaults
const SKIP_SPLASH : bool = false
const SKIP_NG_AUTH : bool = false
const SKIP_MENU : bool = true
const LOG_LEVEL : Log.LogLevel = Log.LogLevel.DEFAULT ## Global log visibility filter override. Default does nothing.
	
## Scene instance references
# Interface nodes
@onready var splash : Node = null
@onready var ng_auth : Node = null
@onready var main_menu : Node = null
@onready var post_processing : Node = null
@onready var loading_screen : Node = null
# Overworld nodes
@onready var overworld : Node2D = null 
@onready var player : Actor = null
@onready var camera : Camera2DPlus = null
