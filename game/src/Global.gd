extends Node
## Main global autoload for Commongrounds
##
## Contains launch parameters, references to key
## objects and instances, debugging options, and 
## global variables that need to be accessible 

signal client_config_file_ready(config_file: ConfigFile)
signal error_shown(message:String)
signal error_freed(message:String)
signal username_avaliable(username:String)
var error_blocking : bool = false
var camera_position : Vector2 = Vector2(0, 0)
