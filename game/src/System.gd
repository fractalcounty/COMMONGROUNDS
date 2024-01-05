extends Node

## Static variables
@onready var is_web_export : bool = OS.has_feature('web')
@onready var is_debug_export : bool = OS.is_debug_build()
@onready var is_web_debug_export : bool = is_web_export and is_debug_export
