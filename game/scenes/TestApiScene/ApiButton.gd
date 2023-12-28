extends Button

@onready var http_request = $HTTPRequest
const URL = "https://api.browse.ai/v2/robots/ac0415f8-bde8-44f7-bb1f-3bfca674ff4a/tasks/4dd6e621-9a8a-419e-b4f5-549694f2aed9"
const headers = ["Authorization: Bearer b4a2a50f-9205-471f-9d3a-66cf39014983:218765be-de49-4604-979c-77416f17b084"]

#signal info(data)

func _on_pressed() -> void:
	http_request.request(URL, headers)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var rawData = JSON.parse_string(body.get_string_from_utf8())

	var data = rawData.result
	var capturedTexts = data["capturedTexts"]
	print(capturedTexts)

