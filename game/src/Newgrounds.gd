extends NGUtils
## Newgrounds.io autoload helper script for Godot 4.x
##
## Provides various methods to call the Newgrounds.io
## API from your scripts with detailed logging
##
## @tutorial(Components):	http://www.newgrounds.io/help/components/
## @tutorial(Objects):		https://www.newgrounds.io/help/objects/

signal request_completed(response_data : Dictionary)
signal connected
signal session_valid
signal do_login(passport_url: String)
signal user_login(user: UserData)

const APP_ID : String = "57486:i7TJksdI" ## Game app ID
const AES_KEY : String = "4tWX2jGEhqoohsboJ5e04Q==" ## AES Base-64 Encryption key
const GATEWAY_URI: String = "https://newgrounds.io/gateway_v3.php"

var user: UserData
var api_request: HTTPRequest

@onready var log : LogStream = LogStream.new("Newgrounds", Log.current_log_level)

enum SessionState {OFFLINE, INVALID, AUTHENTICATING, VALID}
signal is_offline
signal is_invalid
signal is_authenticating
signal is_valid

var is_active_ng_browser_session : bool = false
var current_session_state : SessionState = SessionState.INVALID
var session_id : String = ""
var logged_in : bool = false
var passport_url : String = ""

func change_session_state(new_session_state: SessionState) -> void:
	is_active_ng_browser_session = true if get_session_id_from_url().is_empty() else false
	log.info("Session state changed from '" + str(current_session_state) + "' to " + str(new_session_state) + ". is_active_ng_browser_session: " + str(is_active_ng_browser_session))
	current_session_state = new_session_state
	match current_session_state:
		SessionState.OFFLINE:
			logged_in = false
			is_offline.emit()
			log.info("Session is now offline.")
		SessionState.INVALID:
			logged_in = false
			is_invalid.emit()
			log.info("Session is now invalid. Revalidating...")
			if is_active_ng_browser_session:
				session_id = str(JavaScriptBridge.eval(
				'var urlParams = new URLSearchParams(window.location.search);' +
				'urlParams.get("ngio_session_id");', true))
				if not session_id.is_empty():
					change_session_state(SessionState.AUTHENTICATING)
				else:
					log.error("Session ID is empty. is_active_ng_browser_session: " + str(is_active_ng_browser_session))
					return
			else:
				request("App.startSession", {"force": false}, Callable(self, "_on_start_session"))
		SessionState.AUTHENTICATING:
			logged_in = false
			is_authenticating.emit()
			if session_id.is_empty():
				log.error("Session ID is empty. is_active_ng_browser_session: " + str(is_active_ng_browser_session))
			log.info("Session exists and is valid. Authenticating NG account...")
			request("App.checkSession", {}, Callable(self, "_on_check_session"))
		SessionState.VALID:
			logged_in = true
			is_valid.emit()
			log.info("User session is valid!")

func _on_start_session(results) -> void:
	log.info("App.startSession results: " + str(results))
	var result_data = results.get("result", {}).get("data", {})
	var session_data = result_data.get("session", {})
	
	var new_session_id = session_data.get("id", "")
	if new_session_id and not new_session_id.is_empty():
		session_id = new_session_id
		change_session_state(SessionState.AUTHENTICATING)
	
	var user = result_data.get("user", null)
	var logged_in = user != null
	
	if not logged_in:
		log.info("User not logged in. Sending passport URL.")
		
		var new_passport_url : String = session_data.get("passport_url", "")
		if new_passport_url and not new_passport_url.is_empty():
			passport_url = new_passport_url
			OS.shell_open(passport_url)
			
		log.info("Passport URL: " + str(passport_url))
		do_login.emit(_on_login)
		_wait_for_login()
	else:
		change_session_state(SessionState.AUTHENTICATING)
		log.info("Already logged in: ")

func _on_check_session(results) -> void:
	log.info("App.checkSession results: " + str(results))
	var result_data = results.get("result", {}).get("data", {})
	var session_data = result_data.get("session", {})
	
	var new_session_id = session_data.get("id", "")
	if new_session_id and not new_session_id.is_empty():
		session_id = new_session_id
	
	var user = result_data.get("user", null)
	var logged_in = user != null

func _wait_for_login() -> void:
	if not logged_in and current_session_state == SessionState.AUTHENTICATING:
		await get_tree().create_timer(5.0).timeout
		request("App.checkSession", {}, Callable(self, "_on_session_checked"))
	else:
		_on_login()


## I want to call request("App.checkSession") every 5 seconds as per the Newgrounds docs:
## "While you user is logging in, make a call to App.checkSession every 5 seconds or so
## (hitting the API too fast could trigger our DDOS protection and block your app).
## If they complete their login, you will eventually get a valid 'user' object in the session
## result. If they cancel the login, you will get an error in the return. Either way,
## you will know they have completed some action from the browser window you sent them to.
func _keep_auth_alive():
	while current_session_state == SessionState.AUTHENTICATING:
		await get_tree().create_timer(5.0).timeout
		request("App.checkSession", {}, Callable(self, "_on_keepalive"))

func _on_keepalive(results) -> void:
	var result_data = results.get("result", {}).get("data", {})
	var user = result_data.get("user", null)
	if user != null:
		Log.info("SUCCESS!!")
	
	
	

func _on_login() -> void:
	log.info("User logged in!")
	change_session_state(SessionState.VALID)

func _check_session() -> void:
	request("App.checkSession", {}, Callable(self, "_on_session_checked"))

func _on_session_checked(results) -> void:
	pass
	#log.info("App.checkSession results: " + str(results))

func request(component: String, parameters: Dictionary, callable: Callable = Callable(), on_load_function: Variant = null) -> void:
	#log.info("Requesting component: " + str(component) + " with parameters: " + str(parameters))
	
	## Initialize API request
	var api_request: HTTPRequest = HTTPRequest.new()
	add_child(api_request)
	
	## Append callable functionality
	if callable and not on_load_function:
		api_request.request_completed.connect(_request_completed.bind(callable))
	if callable and on_load_function:
		api_request.request_completed.connect(_request_completed.bind(callable, on_load_function))
	
	## Set up API call parameters
	var call_parameters = {
			"component": component,
			"parameters": parameters,
		}
		
	## Encrypt API call parameters and construct final call parameters
	var encrypted_call_parameters: String = encrypt_data(JSON.stringify(call_parameters), AES_KEY)
	var input_parameters : Dictionary = {}
	
	if current_session_state != SessionState.VALID:
		input_parameters = _unvalidated_input_parameters(encrypted_call_parameters) ## If the user cannot provide user ID
	else:
		input_parameters = _validated_input_parameters(encrypted_call_parameters) ## If the user can provide user ID
 
	## Construct and push finalized request payload
	api_request.request(
		GATEWAY_URI,
		["Content-Type: application/x-www-form-urlencoded"],
		HTTPClient.METHOD_POST,
		"input=" + JSON.stringify(input_parameters).uri_encode()
	)

func _validated_input_parameters(parameters: String) -> Dictionary:
	return {
		"app_id": APP_ID,
		"session_id": session_id,
		"call": {
			"secure": str(parameters),
		}
	}

func _unvalidated_input_parameters(parameters: String) -> Dictionary:
	return {
		"app_id": APP_ID,
		"call": {
			"secure": str(parameters),
		}
	}

func _request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, callable: Callable, on_load_function: Variant = null) -> void:
	log.debug("Request completed. Result: '" + str(result) + "', code: '" + str(response_code) + "', headers: '" + str(headers) + ".")
	if on_load_function:
		callable.call(JSON.parse_string(body.get_string_from_ascii()), on_load_function)
	else:
		callable.call(JSON.parse_string(body.get_string_from_ascii()))
