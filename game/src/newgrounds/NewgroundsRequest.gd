extends HTTPRequest
class_name NewgroundsRequest

@onready var _log : LogStream = LogStream.new("NewgroundsRequest", Log.LogLevel.DEBUG)
@onready var http_request: HTTPRequest = HTTPRequest.new()

func send(component: String, parameters: Dictionary, APP_ID: String, AES_KEY: String, GATEWAY_URI: String, callable: Callable = Callable(), on_load_function: Variant = null) -> void:
	_log.debug("Requesting component: " + str(component) + " with parameters: " + str(parameters))
	
	## Initialize HTTP request
	http_request.request_completed.connect(_on_request_completed.bind(callable, on_load_function))

	if callable and not on_load_function:
		http_request.request_completed.connect(_on_request_completed.bind(callable))
	if callable and on_load_function:
		http_request.request_completed.connect(_on_request_completed.bind(callable, on_load_function))
	
	## Construct request data
	var call_parameters: Dictionary = {"component": component, "parameters": parameters}
	var encrypted_call_parameters: String = NewgroundsCrypto.encrypt(JSON.stringify(call_parameters), AES_KEY)
	var input_parameters: Dictionary = _prepare_input_parameters(encrypted_call_parameters, APP_ID)
	var request_data: String = "input=" + JSON.stringify(input_parameters).uri_encode()

	## Send HTTP request
	_log.debug("REQUEST: " + component)
	var error: Error = http_request.request(GATEWAY_URI, ["Content-Type: application/x-www-form-urlencoded"], HTTPClient.METHOD_POST, request_data)
	if error != OK:
		_log.error("REQUEST SETUP FAILED: HTTPRequest setup failed with error: {error}".format({"error": str(error)}))
		http_request.queue_free()
		return

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, callable: Callable, on_load_function: Variant = null) -> void:
	if response_code != 200:
		_log.error("REQUEST FAILED: {response_code}".format({"response_code": str(response_code)}))
		return

	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	_log.err_cond_not_ok(error, "Error on request completed")
	if error == OK:
		var response : Dictionary = json.data
		_log.debug("RESPONSE PARSED: " + "data: {\n\t" + str(response).replace(", \"", ",\n\t\"") + "\n}")
		
		if response.has("result") and response["result"].has("data"):
			var response_result : Dictionary = response["result"]
			var response_data : Dictionary = response["result"]["data"]
			callable.call(response_data)

func _prepare_input_parameters(encrypted_parameters: String, APP_ID: String) -> Dictionary:
	## Includes the session ID from the session_data resource if it's available
	var input_params: Dictionary = {
		"app_id": APP_ID,
		"call": {
			"secure": encrypted_parameters
		}
	}
	input_params["session_id"] = "local_session_id"
	return input_params

#func is_session_in_url() -> bool:
	#var js : String = 'var urlParams = new URLSearchParams(window.location.search);' + 'urlParams.get("ngio_session_id");'
	#var result : String  = str(JavaScriptBridge.eval(js, true))
	#if result.length() < 8:
		#return false
	#else:
		#return false
