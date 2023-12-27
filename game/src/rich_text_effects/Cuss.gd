@tool
extends RichTextEffect
class_name TextEffectCuss

# Syntax: [cuss][/cuss]
var bbcode = "cuss"

var VOWELS = ["a", "e", "i", "o", "u", "A", "E", "I", "O", "U"]
var CHARS = ["&", "$", "!", "@", "*", "#", "%"]

var _was_space = false
const SPACE = 32  # Unicode code point for space character

func _process_custom_fx(char_fx):
	var c = char_fx.glyph_index

	if not _was_space and not char_fx.relative_index == 0 and not c == SPACE:
		var t = char_fx.elapsed_time + c * 10.2 + char_fx.range.x * 2
		t *= 4.3
		if c in VOWELS or sin(t) > 0.0:
			char_fx.glyph_index = CHARS[int(t) % CHARS.size()].unicode_at(0)
	
	_was_space = c == SPACE

	return true
