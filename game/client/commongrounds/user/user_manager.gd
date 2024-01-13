extends Node
class_name UserManager

@export var local_player : Player
var user_scene: PackedScene = preload("res://client/world/user/User.tscn")

var local_player_newgrounds_id : String = ""
var local_player_newgrounds_name : String = ""

local_player.s
