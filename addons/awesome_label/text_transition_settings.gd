@tool
extends Node

var transitions: Dictionary = {}

func register(rich_text_transition: RichTextLabel) -> void:
	transitions[rich_text_transition.id] = rich_text_transition

func unregister(rich_text_transition: RichTextLabel) -> void:
	transitions.erase(rich_text_transition.id)
