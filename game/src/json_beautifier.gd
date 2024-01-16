#=============================================================================#
# JSON Beautifier                                                             #
# Copyright (C) 2018-Present Michael Alexsander                               #
#-----------------------------------------------------------------------------#
# This Source Code Form is subject to the terms of the Mozilla Public         #
# License, v. 2.0. If a copy of the MPL was not distributed with this         #
# file, You can obtain one at http://mozilla.org/MPL/2.0/.                    #
#=============================================================================#

class_name JSONBeautifier
## Helper class for formatting JSON strings.
##
## This helper class can be used with JSON strings to "beautify" (format with
## the proper new lines, indentations, and spaces) or the "uglify" (remove all
## formatting) them.


## Takes valid JSON (if invalid, it will return an empty string and push the
## parsing error message to the debugger output) and a number of spaces for
## indentation (default is [code]0[/code], in which it will use tabs instead),
## returning properly formatted JSON.
static func beautify_json(text: String, spaces := 0) -> String:
	var json := JSON.new()
	if json.parse(text) != OK:
		push_error("Can't beautify, JSON error at line " +
				str(json.get_error_line()) + ": " + json.get_error_message())

		return ""

	var indentation := ""
	if spaces > 0:
		for i: int in spaces:
			indentation += " "
	else:
		indentation = "\t"

	var quotation_start := -1
	var char_position := 0
	for i: String in text:
		# Workaround a Godot quirk, as it allows JSON strings to end with a
		# trailing comma.
		if i == "," and char_position + 1 == text.length():
			break

		# Avoid formating inside strings.
		if i == "\"":
			if quotation_start == -1:
				quotation_start = char_position
			elif text[char_position - 1] != "\\":
				quotation_start = -1

			char_position += 1

			continue
		elif quotation_start != -1:
			char_position += 1

			continue

		match i:
			# Remove pre-existing formatting.
			" ", "\n", "\t":
				text[char_position] = ""
				char_position -= 1
			"{", "[", ",":
				if text[char_position + 1] != "}" and\
						text[char_position + 1] != "]":
					text = text.insert(char_position + 1, "\n")
					char_position += 1
			"}", "]":
				if text[char_position - 1] != "{" and\
						text[char_position - 1] != "[":
					text = text.insert(char_position, "\n")
					char_position += 1
			":":
				text = text.insert(char_position + 1, " ")
				char_position += 1

		char_position += 1

	for i: Array[String] in [["{", "}"] as Array[String], ["[", "]"]\
			as Array[String]] as Array[Array]:
		var bracket_start: int = text.find(i[0])
		while bracket_start != -1:
			var bracket_end: int = text.find("\n", bracket_start)
			var bracket_count := 0
			while bracket_end != - 1:
				if text[bracket_end - 1] == i[0]:
					bracket_count += 1
				elif text[bracket_end + 1] == i[1]:
					bracket_count -= 1

				# Move through the indentation to see if there is a match.
				while text[bracket_end + 1] == indentation[0]:
					bracket_end += 1

					if text[bracket_end + 1] == i[1]:
						bracket_count -= 1

				if bracket_count <= 0:
					break

				bracket_end = text.find("\n", bracket_end + 1)

			# Skip one newline so the end bracket doesn't get indented.
			bracket_end = text.rfind("\n", text.rfind("\n", bracket_end) - 1)
			while bracket_end > bracket_start:
				text = text.insert(bracket_end + 1, indentation)
				bracket_end = text.rfind("\n", bracket_end - 1)

			bracket_start = text.find(i[0], bracket_start + 1)

	return text


## Takes valid JSON (if invalid, it will return an empty string and push the
## parsing error message to the debugger output), returning compacted JSON into
## a single line.
static func uglify_json(text: String) -> String:
	var json := JSON.new()
	if json.parse(text) != OK:
		push_error("Can't uglify, JSON error at line " +
				str(json.get_error_line()) + ": " + json.get_error_message())

		return ""

	var quotation_start := -1
	var char_position := 0
	for i: String in text:
		# Avoid formating inside strings.
		if i == '"':
			if quotation_start == -1:
				quotation_start = char_position
			elif text[char_position - 1] != "\\":
				quotation_start = -1

			char_position += 1

			continue
		elif quotation_start != -1:
			char_position += 1

			continue

		if i == " " or i == "\n" or i == "\t":
			text[char_position] = ""
			char_position -= 1

		char_position += 1

	return text
