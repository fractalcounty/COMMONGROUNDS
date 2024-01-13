@tool
extends RichTextEffect
class_name TextEffectUwU


# Syntax: [uwu][/uwu]
var bbcode = "uwu"


const r = ["r"]
const R = ["R"]
const l = ["l"]
const L = ["L"]

const w = ["w"]
const W = ["W"]


func _process_custom_fx(char_fx):
	match char_fx.glyph_index:
		r, l: char_fx.glyph_index = w
		R, L: char_fx.glyph_index = W
	return true
