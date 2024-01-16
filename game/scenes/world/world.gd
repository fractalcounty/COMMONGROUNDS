extends Node2D

@export var log_level: LogStream.LogLevel

@onready var camera : Camera2DPlus = $Camera2DPlus
@onready var player : Player = $Player

@onready var _log : LogStream = LogStream.new("World", log_level)

func _ready() -> void:
	pass
