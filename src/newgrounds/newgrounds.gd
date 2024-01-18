extends Node
## Newgrounds.io API script for Godot 4.x
##
## Provides various methods to call the Newgrounds.io
## API from your scripts with detailed logging
##
## @tutorial(Components):	http://www.newgrounds.io/help/components/
## @tutorial(Objects):		https://www.newgrounds.io/help/objects/

signal session_updated(session: NewgroundsSession)
signal user_updated(user: NewgroundsUser)
signal user_icons_updated(user_icons: NewgroundsUserIcons)
signal passport_url_updated(passport_url: String)

const APP_ID : String = "57486:i7TJksdI" ## Game app ID
const AES_KEY : String = "4tWX2jGEhqoohsboJ5e04Q==" ## AES Base-64 Encryption key
const GATEWAY_URI: String = "https://newgrounds.io/gateway_v3.php" ## URI to Newgrounds API gateway
const MAX_RETRIES : int = 5

var keepalive_delay : float = 1.0
var retry_count : int = 0
@onready var keepalive_timer : Timer = $KeepaliveTimer

# Objects
var session: NewgroundsSession = null

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var log_level : LogStream.LogLevel = Global.newgrounds_log_level
@onready var _log : LogStream = LogStream.new("Newgrounds", log_level)

func initialize() -> void:
	request("App.checkSession", {}, Callable(self, "_on_session_checked"))

func _on_session_checked(response_data: Dictionary) -> void:
	if response_data.has("session") and response_data["session"].has("id"):
		retry_count = 0
		_log.debug("_on_session_checked: Session ID found in response. Serving session object in memory.")
		if not session:
			session = NewgroundsSession.new()
		session.call_deferred("initialize", response_data["session"])
		session_updated.emit(session)
		_log.debug("Session updated: " + str(session))

	else: # If session does not exist in response
		session = null # Free objects from memory
		_log.warn("_on_session_checked error: No session found in API response data. Attempting to start session...")
		
		if retry_count != MAX_RETRIES:
			request("App.startSession", {"force": true}, Callable(self, "_on_session_started"))
			retry_count += 1
		else:
			_log.fatal("_on_session_checked error: Attempted too many retries to start session.")
		
	if response_data.has("error") and response_data["error"]["code"] != 102:
		_log.error("_on_session_checked error:" + str(response_data["error"]["code"]))
	
func _on_session_started(response_data: Dictionary) -> void:
	if response_data["session"]["id"]:
		retry_count = 0
		_log.debug("_on_session_started: Session ID found in response. Creating session object created in memory.")
		request("App.checkSession", {}, Callable(self, "_on_session_checked"))

func request(component: String, parameters: Dictionary, callable: Callable = Callable(), on_load_function: Variant = null) -> void:
	_log.info("Requesting component: " + str(component) + " with parameters: " + str(parameters))
	
	## Initialize HTTP request
	http_request.request_completed.connect(_on_request_completed.bind(callable, on_load_function))

	if callable and not on_load_function:
		http_request.request_completed.connect(_on_request_completed.bind(callable))
	if callable and on_load_function:
		http_request.request_completed.connect(_on_request_completed.bind(callable, on_load_function))
	
	## Construct request data
	var call_parameters: Dictionary = {"component": component, "parameters": parameters}
	var encrypted_call_parameters: String = NewgroundsCrypto.encrypt(JSON.stringify(call_parameters), AES_KEY)
	var input_parameters: Dictionary = _prepare_input_parameters(encrypted_call_parameters)
	var request_data: String = "input=" + JSON.stringify(input_parameters).uri_encode()

	## Send HTTP request
	var error: Error = http_request.request(GATEWAY_URI, ["Content-Type: application/x-www-form-urlencoded"], HTTPClient.METHOD_POST, request_data)
	if error != OK:
		_log.error("REQUEST SETUP FAILED: HTTPRequest setup failed with error: {error}".format({"error": str(error)}))
		http_request.queue_free()
		return

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, callable: Callable, on_load_function: Variant = null) -> void:
	if response_code != 200:
		_log.error("REQUEST FAILED: Response code: " + str(response_code))
		return

	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	_log.err_cond_not_ok(error, "Error on request completed")
	if error == OK:
		var response : Dictionary = json.data
		var data : Variant = json.get_data()
		_log.debug("RESPONSE PARSED: " + JSONBeautifier.beautify_json(json.stringify(data)))
		
		if response.has("result") and response["result"].has("data"):
			var response_result : Dictionary = response["result"]
			var response_data : Dictionary = response["result"]["data"]
			callable.call(response_data)

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
		_log.debug("Retrieved session ID from URL.")
	elif session:
		_log.debug("Retrieved session ID from API response.")
		input_params["session_id"] = session.id
	return input_params

func is_session_in_url() -> bool:
	var js : String = 'var urlParams = new URLSearchParams(window.location.search);' + 'urlParams.get("ngio_session_id");'
	var result : String  = str(JavaScriptBridge.eval(js, true))
	if result.length() < 8:
		return false
	else:
		return false


func _on_keepalive_timer_timeout() -> void:
	request("App.checkSession", {}, Callable(self, "_on_session_checked"))
	keepalive_timer.keepalive(keepalive_delay)
