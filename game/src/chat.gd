extends CanvasLayer
## Chat singleton script

@onready var margin_container : MarginContainer = $ScreenControl/MarginContainer
@onready var label : RichTextLabel = $ScreenControl/MarginContainer/PanelContainer/VBoxContainer/RichTextLabel
@onready var line_edit : LineEdit = $ScreenControl/MarginContainer/PanelContainer/VBoxContainer/LineEdit
@onready var username : String = 'username'
@onready var actor : Actor = null

var focused : bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_ENTER:
			if not focused:
				if not margin_container.visible:
					start()  # or margin_container.show()
			
				line_edit.grab_focus()
				focused = true
				get_viewport().set_input_as_handled()
			else:
				_on_line_edit_text_submitted(line_edit.text)
			
func _ready() -> void:
	label.bbcode_enabled = true
	clear()
	if margin_container.visible:
		margin_container.hide()
	add_message('Welcome to the COMMONGROUNDS!', '', true)

func start() -> void:
	margin_container.show()

func stop() -> void:
	margin_container.hide()

func clear() -> void:
	label.clear()

func _escape_bbcode(bbcode_text: String) -> String:
	return bbcode_text.replace("[", "[lb]")

func add_message(content: String, prefix: String = '', system: bool = false) -> void:
	var escaped_content : String = _escape_bbcode(content) ## Escape content to prevent BBCode injection
	var formatted_prefix : String = "[b]" + _escape_bbcode(prefix) + ":[/b] " if prefix != '' else ""
	var full_message : String = formatted_prefix + escaped_content ## Construct the full message

	if system: ## If this is a system message, apply system BBCode styling to the entire message and print to console
		full_message = "[b][color=orange]" + full_message + "[/color][/b]"
		print(full_message)

	label.append_text(full_message + "\n")
	label.scroll_to_line(label.get_line_count())

func _on_line_edit_text_submitted(new_text: String) -> void:
	add_message(new_text, username, false)
	actor.visual.speech.say(new_text)
	line_edit.clear()
	line_edit.release_focus()
	focused = false


func _on_panel_container_focus_entered() -> void:
	pass


func _on_panel_container_focus_exited() -> void:
	pass


func _on_line_edit_focus_entered() -> void:
	#add_message('line_edit', 'focus entered', true)
	focused = true


func _on_line_edit_focus_exited() -> void:
	#add_message('line_edit', 'focus exited', true)
	focused = false


func _on_screen_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		line_edit.release_focus()
		focused = false

func _on_margin_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		line_edit.release_focus()
		focused = false
