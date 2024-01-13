extends VBoxContainer

@onready var speech_container_scene : PackedScene = preload("res://client/player/SpeechContainer.tscn")

func _ready() -> void:
	pass

func _escape_bbcode(bbcode_text: String) -> String:
	return bbcode_text.replace("[", "[lb]")

func say(message : String) -> void:
	var escaped_content : String = _escape_bbcode(message) ## Escape content to prevent BBCode injection
	var full_message : String = '[center][bounce wave=15.0]' + escaped_content + '[/bounce][/center]' ## Construct the full message

	var new_speech_container : PanelContainer = speech_container_scene.instantiate()
	add_child(new_speech_container)
	
	var label = new_speech_container.get_node("SpeechLabel") as RichTextLabel
	label.clear()
	label.append_text(full_message + "\n")
	label.scroll_to_line(label.get_line_count())
