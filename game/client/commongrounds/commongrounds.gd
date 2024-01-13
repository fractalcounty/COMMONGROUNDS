extends Node2D
class_name Commongrounds

@export var local_player_node : Player
@export var commongrounds_session : CommongroundsSession
var user_scene: PackedScene = preload("res://client/commongrounds/user/User.tscn")

func _ready() -> void:
	local_player_node.set_player_name(Global.local_player_id)

func spawn_user() -> User:
	var user : User = user_scene.instantiate() as User
	add_child(user)
	return user
