@tool
extends LogStream

func _init():
	super("Global", Log.LogLevel.DEBUG if OS.has_feature("debug") else Log.LogLevel.INFO)
	
func _ready():
	if Global.LOG_LEVEL != LogStream.LogLevel.DEFAULT:
		self.current_log_level = Global.LOG_LEVEL

