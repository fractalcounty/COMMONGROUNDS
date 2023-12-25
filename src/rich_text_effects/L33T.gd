@tool
extends RichTextEffect
class_name TextEffectL33T

# Syntax: [l33t][/l33t]
var bbcode = "l33t"


var leet = {
	["L"]: ["1"],
	["l"]: ["1"],
	["I"]: ["1"],
	["i"]: ["1"],
	["E"]: ["3"],
	["e"]: ["3"],
	["T"]: ["7"],
	["t"]: ["7"],
	["S"]: ["5"],
	["s"]: ["5"],
	["A"]: ["4"],
	["a"]: ["4"],
	["O"]: ["0"],
	["o"]: ["0"],
}


func _process_custom_fx(char_fx):
	if char_fx.glyph_index in leet:
		char_fx.glyph_index = leet[char_fx.glyph_index]
	return true
