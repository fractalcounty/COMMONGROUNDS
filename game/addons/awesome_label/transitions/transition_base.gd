extends RichTextEffect

const HALFPI = PI / 2.0
var space = " ".unicode_at(0)

func get_color(s) -> Color:
	if s is Color:
		return s
	elif s[0] == '#':
		return Color(s)
	# For color names, consider defining a mapping or using a different approach
	else:
		print("Color name handling not implemented.")
		return Color(1, 1, 1)  # Default to white or any other fallback color

func get_rand(char_fx) -> float:
	return fmod(get_rand_unclamped(char_fx), 1.0)

func get_rand_unclamped(char_fx) -> float:
	# Adjusted to use glyph_index instead of character
	return char_fx.glyph_index * 33.33 + char_fx.range.x * 4545.5454

func get_rand_time(char_fx, time_scale: float = 1.0) -> float:
	# Adjusted to use glyph_index instead of character
	return char_fx.glyph_index * 33.33 + char_fx.range.x * 4545.5454 + char_fx.elapsed_time * time_scale

func get_tween_data(char_fx):
	var id = char_fx.env.get("id", "main")
	if not id in TextTransitionSettings.transitions:
		print("No RichTextTransition with id", id, "is registered.")
		return null
	else:
		return TextTransitionSettings.transitions[id]

func get_t(char_fx) -> float:
	var tween_data = get_tween_data(char_fx)
	if tween_data:
		return tween_data.get_t(char_fx.range.x)
	else:
		return 0.0  # Return a default value if tween data is not found
