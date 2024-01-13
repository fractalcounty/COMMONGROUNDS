extends NGEncrypt
class_name NewgroundsSession
## Newgrounds.io API script for Godot 4.x
##
## Provides various methods to call the Newgrounds.io
## API from your scripts with detailed logging
##
## @tutorial(Components):	http://www.newgrounds.io/help/components/
## @tutorial(Objects):		https://www.newgrounds.io/help/objects/

signal connecting
signal authorizing
signal newgrounds_login_url_generated(url: String)
signal healthy
signal session_killed

const APP_ID : String = "57486:i7TJksdI" ## Game app ID
const AES_KEY : String = "4tWX2jGEhqoohsboJ5e04Q==" ## AES Base-64 Encryption key
const GATEWAY_URI: String = "https://newgrounds.io/gateway_v3.php" ## URI to Newgrounds API gateway
const MAX_RETRIES : int = 5
const TIMEOUT : float = 5.0

var keepalive_delay : float = 5.0
var api_request: HTTPRequest
var retry_count : int = 0
var local_session_id : String = ""
var local_user_name : String = ""
var current_user : Dictionary = {}
var confirm : bool = true

@onready var log : LogStream = LogStream.new("Newgrounds", Log.LogLevel.INFO)

enum State {CONNECTING, AUTHORIZING, OK}
var current_state: State = State.CONNECTING

func change_state(new_state: State) -> void:
	current_state = new_state
	match current_state:
		State.CONNECTING:
			keepalive_delay = 5.0
			connecting.emit()
		State.AUTHORIZING:
			keepalive_delay = 3.0
			authorizing.emit()
		State.OK:
			healthy.emit()
			Global.username_avaliable.emit(str(current_user["name"]))
			keepalive_delay = 15.0

func _ready() -> void:
	change_state(State.CONNECTING)
	request("App.checkSession", {}, Callable(self, "_on_session_checked"))
	_keepalive()

func _keepalive() -> void:
	_on_keepalive()

func _on_keepalive() -> void:
	await get_tree().create_timer(keepalive_delay).timeout
	request("App.checkSession", {}, Callable(self, "_on_session_checked"))
	_keepalive()

func _on_session_started(response_data: Dictionary) -> void:
	if response_data.has("session") and response_data["session"].has("id"):
		local_session_id = response_data["session"]["id"]
		log.info("Started session: " + str(response_data["session"]["id"]))
		change_state(State.AUTHORIZING)
		if response_data["session"].has("user"):
			if response_data["session"]["user"]:
				current_user = response_data["user"]
				local_user_name = response_data["session"]["user"]["name"]
				change_state(State.OK)
				log.info("User logged in: " + str(response_data["session"]["user"]))
			elif response_data["session"].has("passport_url"):
				current_user = {}
				#var uri : String = str(response_data["session"]["passport_url"].uri_encode()) #WARNING: Check if needs encoding on web
				var url: String = str(response_data["session"]["passport_url"])
				newgrounds_login_url_generated.emit(url)
				log.info("Redirecting user to login at: " + str(response_data["session"]["passport_url"]))
		
func _on_session_checked(response_data: Dictionary) -> void:
	if response_data.has("session") and response_data["session"].has("id"):
		local_session_id = response_data["session"]["id"]
		
		log.debug("Checked session and it exists at: " + str(response_data["session"]["id"]))
		if response_data["session"] and response_data["session"]["user"] and response_data["session"]["user"]["name"]:
			current_user = response_data["session"]["user"]
			local_user_name = response_data["session"]["user"]["name"]
			change_state(State.OK)
			if confirm:
				log.info("User logged in: " + str(response_data["session"]["user"]["name"]))
				confirm = false
			retry_count = 0
		else:
			local_user_name = ""
			current_user = {}
			change_state(State.AUTHORIZING)
			log.debug("User not logged in yet")
	else:
		change_state(State.CONNECTING)
		local_user_name = ""
		local_session_id = ""
		if response_data.has("error"):
			var error : Dictionary = response_data["error"]
			if error.has("message"):
				var error_code : String = error["message"]
				var error_msg : float = error["code"]
				if retry_count < MAX_RETRIES:
					await _attempt_start_session(error_code)
				else:
					log.error("Maximum retry attempts reached. Unable to start session. Killing self.")
					session_killed.emit()

func _attempt_start_session(error_code: String) -> void:
	if current_state == State.CONNECTING:
		retry_count += 1
		log.info("Error checking session: " + error_code + ". Retrying... Attempt #" + str(retry_count))
		await get_tree().create_timer(1.0).timeout
		request("App.startSession", {"force": true}, Callable(self, "_on_session_started"))

func request(component: String, parameters: Dictionary, callable: Callable = Callable(), on_load_function: Variant = null) -> void:
	log.debug("Requesting component: " + str(component) + " with parameters: " + str(parameters))
	
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
	var encrypted_call_parameters: String = encrypt(JSON.stringify(call_parameters), AES_KEY)
	var input_parameters: Dictionary = _prepare_input_parameters(encrypted_call_parameters)
	var request_data: String = "input=" + JSON.stringify(input_parameters).uri_encode()

	## Send HTTP request
	log.debug("REQUEST: " + component)
	var error: Error = http_request.request(GATEWAY_URI, ["Content-Type: application/x-www-form-urlencoded"], HTTPClient.METHOD_POST, request_data)
	if error != OK:
		log.error("REQUEST SETUP FAILED: HTTPRequest setup failed with error: {error}".format({"error": str(error)}))
		http_request.queue_free()
		return

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, callable: Callable, on_load_function: Variant = null) -> void:
	if response_code != 200:
		log.error("REQUEST FAILED: {response_code}".format({"response_code": str(response_code)}))
		return

	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	log.err_cond_not_ok(error, "Error on request completed")
	if error == OK:
		var response : Dictionary = json.data
		log.debug("RESPONSE PARSED: " + "data: {\n\t" + str(response).replace(", \"", ",\n\t\"") + "\n}")
		
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
		log.debug("Retrieved session ID from URL.")
	elif not local_session_id.is_empty():
		log.debug("Retrieved session ID from API response.")
		input_params["session_id"] = local_session_id
	return input_params

func is_session_in_url() -> bool:
	var js : String = 'var urlParams = new URLSearchParams(window.location.search);' + 'urlParams.get("ngio_session_id");'
	var result : String  = str(JavaScriptBridge.eval(js, true))
	if result.length() < 8:
		return false
	else:
		return false
