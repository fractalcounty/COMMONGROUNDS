extends Button

@onready var http_request = $HTTPRequest
#const URL = "https://api.browse.ai/v2/robots/ac0415f8-bde8-44f7-bb1f-3bfca674ff4a/tasks/ad16bfb7-c4ac-4ed3-bc23-422b6f35d8b0"
const URL = "https://api.browse.ai/v2/robots/ac0415f8-bde8-44f7-bb1f-3bfca674ff4a/tasks?sort=-createdAt&page=1&"
const headers = ["Authorization: Bearer b4a2a50f-9205-471f-9d3a-66cf39014983:218765be-de49-4604-979c-77416f17b084"]
#b29c5d58-8769-4229-b80b-b041e08871d3
#signal info(data)
var rawData
var id

func _on_pressed() -> void:
	http_request.request(URL, headers)
	

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	rawData = JSON.parse_string(body.get_string_from_utf8())
	
	id = rawData["result"]["robotTasks"]["items"][0]["id"]
	print(id)
	#var capturedTexts = data["capturedTexts"]
	

