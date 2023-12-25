@tool
extends "res://addons/awesome_label/transitions/transition_base.gd"
class_name TextTransPrickle

# Syntax: [prickle pow][/prickle]
var bbcode = "prickle"

func _process_custom_fx(char_fx):
	var power = char_fx.env.get("pow", 2.0)
	var t = get_t(char_fx)
	var r = get_rand(char_fx)
	var a = clamp(t * 2.0 - r, 0.0, 1.0)
	a = pow(a, power)
	char_fx.color.a = 1.0 - a
	return true
