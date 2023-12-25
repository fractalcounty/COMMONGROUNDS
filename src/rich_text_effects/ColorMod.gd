@tool
extends RichTextEffect
class_name TextEffectColorMod

# Syntax: [colormod pow][/colormod]
var bbcode = "colormod"

func _process_custom_fx(char_fx):
	var t = smoothstep(0.3, 0.6, sin(char_fx.elapsed_time * 4.0) * .5 + .5)
	char_fx.color = lerp(char_fx.color, Color.BLUE, t)
	return true
