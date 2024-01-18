extends Node
## Main global autoload for Commongrounds
##
## Contains launch parameters, references to key
## objects and instances, debugging options, and 
## global variables that need to be accessible 

signal client_config_file_ready(config_file: ConfigFile)
signal ready_to_crash

@onready var client_log_level: LogStream.LogLevel = LogStream.LogLevel.INFO
@onready var newgrounds_log_level: LogStream.LogLevel = LogStream.LogLevel.INFO
@onready var config_log_level: LogStream.LogLevel = LogStream.LogLevel.DEBUG
@onready var camera_log_level: LogStream.LogLevel = LogStream.LogLevel.INFO
@onready var input_manager_log_level: LogStream.LogLevel = LogStream.LogLevel.DEBUG
