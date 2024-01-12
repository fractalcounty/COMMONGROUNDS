@tool
extends LogStream

func _init():
	super("Global", Log.LogLevel.DEBUG if OS.has_feature("debug") else Log.LogLevel.INFO)
	
func _ready():
	pass
