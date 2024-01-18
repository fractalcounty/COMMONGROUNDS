@tool
extends RichTextEffect
class_name TextEffectNumber


# Syntax: [number][/number]
var bbcode = "number"


const COMMA = [","]
const SPACE = [" "]
const PERIOD = ["."]

var space = " ".unicode_at(0)
var period = ".".unicode_at(0)
var comma = ",".unicode_at(0)

var _last_char_was_number:bool = false
var _last_word_was_number:bool = false


func get_color(s) -> Color:
	if s is Color: return s
	elif s[0] == '#': return Color(s)
	else: return Color(s)


func _process_custom_fx(char_fx):
	var number_color:Color = get_color(char_fx.env.get("color", Color.YELLOW))
	
	# Reset on first character.
	if char_fx.relative_index == 0:
		_last_char_was_number = false
		_last_word_was_number = false
	
	# If the following is a word, and it came after a number, we'll colorize it.
	if char_fx.glyph_index == space:
		if _last_char_was_number:
			_last_word_was_number = true
		else:
			_last_word_was_number = false
	
	# Colorize characters after a number, except for the period.
	if _last_word_was_number and char_fx.character != period:
		char_fx.color = number_color
	
	# If character is a number, color it.
	if char_fx.glyph_index >= 48 and char_fx.glyph_index <= 57:
		char_fx.color = number_color
		_last_char_was_number = true
	# Colorize trailing commas and periods.
	elif _last_char_was_number and (char_fx.glyph_index == comma):
		char_fx.color = number_color
		_last_char_was_number = false
	else:
		_last_char_was_number = false
	return true
