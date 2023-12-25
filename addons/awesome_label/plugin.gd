@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("AwesomeLabel", "RichTextLabel", preload("awesome_label.gd"), preload("icon2.svg"))

func _exit_tree():
	remove_custom_type("AwesomeLabel")
