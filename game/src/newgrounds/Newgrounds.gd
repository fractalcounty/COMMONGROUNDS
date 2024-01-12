extends Node
## Newgrounds.io API autoload for Godot 4.x
##
## Provides various methods to call the Newgrounds.io
## API from your scripts with detailed logging
##
## @tutorial(Components):	http://www.newgrounds.io/help/components/
## @tutorial(Objects):		https://www.newgrounds.io/help/objects/

signal logging_in

const APP_ID : String = "57486:i7TJksdI" ## Game app ID
const AES_KEY : String = "4tWX2jGEhqoohsboJ5e04Q==" ## AES Base-64 Encryption key
const GATEWAY_URI: String = "https://newgrounds.io/gateway_v3.php" ## URI to Newgrounds API gateway
const MAX_RETRIES : int = 5
const TIMEOUT : float = 5.0
const KEEPALIVE : float = 5.0

enum State {
	SESSION_STARTING,
	SESSION_UPDATING,
	SESSION_AUTHENTICATING,
	
}

var api_request: HTTPRequest
var continue_session_check: bool = true
var retry_count : int = 0
var keepalive_timer : Timer

var user : Dictionary

var latest_result : Dictionary = {}  # Global variable to store the latest result
var last_id : String = ""
@onready var log : LogStream = LogStream.new("Newgrounds", Log.current_log_level)

func _ready() -> void:
	keepalive_timer = Timer.new()
	keepalive_timer.wait_time = KEEPALIVE
	keepalive_timer.autostart = true
	keepalive_timer.timeout.connect(_keepalive)
	add_child(keepalive_timer)
	keepalive_timer.start()
	Newgrounds.request("App.checkSession", {}, Callable(self, "_on_session_checked"))

func _keepalive() -> void:
	if latest_result.has("session") and latest_result["session"].has("id"):
		log.debug("Keeping session alive at ID: " + str(latest_result["session"]["id"]))
		Newgrounds.request("App.checkSession", {}, Callable(self, "_on_session_checked"))
	else:
		pass

func _on_session_started(result: Dictionary) -> void:
	# Check if the 'data' key exists and if 'success' is false
	pass
		
func _on_session_checked(result: Dictionary) -> void:
	if result.has("data") and not result["data"]["success"]:
		var data = result["data"]
		if data.has("error"):
			var error_data = data["error"]
			log.error("Error checking session: " + str(error_data))
			if error_data.has("message") and error_data.has("code"):
				if error_data["message"] == "Missing valid session_id." and error_data["code"] == 102:
					Newgrounds.request("App.startSession", {"force": true}, Callable(self, "_on_session_started"))

func request(component: String, parameters: Dictionary, callable: Callable = Callable(), on_load_function: Variant = null) -> void:
	log.info("Requesting component: " + str(component) + " with parameters: " + str(parameters))
	
	## Initialize HTTP request
	var http_request : HTTPRequest = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed.bind(callable, on_load_function))

	if callable and not on_load_function:
		http_request.request_completed.connect(_on_request_completed.bind(callable))
	if callable and on_load_function:
		http_request.request_completed.connect(_on_request_completed.bind(callable, on_load_function))
	
	## Construct request data
	var call_parameters: Dictionary = {"component": component, "parameters": parameters}
	var encrypted_call_parameters: String = CryptoHelper.encrypt(JSON.stringify(call_parameters), AES_KEY)
	var input_parameters: Dictionary = _prepare_input_parameters(encrypted_call_parameters)
	var request_data: String = "input=" + JSON.stringify(input_parameters).uri_encode()

	## Send HTTP request
	log.debug("Sending request to component: " + component)
	var error: Error = http_request.request(GATEWAY_URI, ["Content-Type: application/x-www-form-urlencoded"], HTTPClient.METHOD_POST, request_data)
	if error != OK:
		log.error("HTTPRequest setup failed with error: {error}".format({"error": str(error)}))
		http_request.queue_free()
		return

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, callable: Callable, on_load_function: Variant = null) -> void:
	log.debug("Request completed. Result: {result}, code: {response_code}".format({"result": str(result), "response_code": str(response_code)}))
	
	if response_code != 200:
		log.error("HTTP Request failed with code: {response_code}".format({"response_code": str(response_code)}))
		return

	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	log.err_cond_not_ok(error, "Error on request completed")
	if error == OK:
		var response : Dictionary = json.data
		log.debug("Response parsed: " + "data: {\n\t" + str(response).replace(", \"", ",\n\t\"") + "\n}")
		
		if response.has("result"):
			latest_result = response["result"]
			if response["result"].has("data"):
				latest_result = response["result"]["data"]
		
				if latest_result.has("session") and latest_result["session"].has("id"):
					last_id = latest_result["session"].get("id")
					var session = latest_result["session"]
					log.debug("Session updated: " + str(session))
		
					if session.has("user"):
						if session["user"] != null:
							if session["user"].has("name"):
								user = session["user"]
								log.debug("User updated: " + str(user["name"]))
						else:
							log.info("Redirecting user to passport URL at: " + str(session["passport_url"]))
							OS.shell_open(session["passport_url"])
		
		if on_load_function:
			callable.call(JSON.parse_string(body.get_string_from_ascii()), on_load_function)
		else:
			callable.call(JSON.parse_string(body.get_string_from_ascii()))

func _prepare_input_parameters(encrypted_parameters: String) -> Dictionary:
	## Includes the session ID from the session_data resource if it's available
	var input_params: Dictionary = {
		"app_id": APP_ID,
		"call": {
			"secure": encrypted_parameters
		}
	}
	if is_session_in_url():
		#input_params["session_id"] = get_session_id_from_url()
		log.warn("found session ID from url")
	elif not last_id.is_empty():
		log.warn("found session ID from api: " + str(last_id))
		input_params["session_id"] = last_id
	else:
		log.warn("couldnt find  gosh dang session id anywhere in input parameters")
	return input_params

func is_session_in_url() -> bool:
	var js : String = 'var urlParams = new URLSearchParams(window.location.search);' + 'urlParams.get("ngio_session_id");'
	var result : String  = str(JavaScriptBridge.eval(js, true))
	if result.length() < 8:
		return false
	else:
		return false
