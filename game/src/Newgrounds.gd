extends NGUtils
## Newgrounds.io API autoload for Godot 4.x
##
## Provides various methods to call the Newgrounds.io
## API from your scripts with detailed logging
##
## @tutorial(Components):	http://www.newgrounds.io/help/components/
## @tutorial(Objects):		https://www.newgrounds.io/help/objects/

signal initialized

const APP_ID : String = "57486:i7TJksdI" ## Game app ID
const AES_KEY : String = "4tWX2jGEhqoohsboJ5e04Q==" ## AES Base-64 Encryption key
const GATEWAY_URI: String = "https://newgrounds.io/gateway_v3.php" ## URI to Newgrounds API gateway

## Data resources
var session_data: NGSessionData 
var user_data: NGUserData
var user_icon_data: NGUserIconsData
var api_request: HTTPRequest

var continue_session_check: bool = true

@onready var log : LogStream = LogStream.new("Newgrounds", Log.current_log_level)

func initialize() -> void:
	log.info("Initializing Newgrounds.io session...")
	request("App.startSession", {"force": true}, Callable(self, "_on_start_session"))

func _on_start_session(results) -> void:
	var result_data: Dictionary = results.get("result", {}).get("data", {})
	log.info("Successfully started Newgrounds.io session and stored response data")
	_update_session_data(result_data)

func _update_session_data(result_data: Dictionary) -> void:
	var session_obj: Dictionary = result_data.get("session", {})
	session_data = NGSessionData.new()
	session_data.id = session_obj.get("id", "")
	session_data.passport_url = session_obj.get("passport_url", "")
	session_data.remember = session_obj.get("remember", false)
	log.info("Saved App.startSession session data to resource: " + str(session_data))
	
	if "user" in session_obj and session_obj["user"]:
		log.info("User already logged in. Getting user data... ")
		_get_user_data(session_obj)
	else:
		log.info("User not logged in. Starting authentification process...")
		_handle_user_login(session_obj)
		
func _handle_user_login(session_obj: Dictionary) -> void:
	var passport_url: String = session_obj.get("passport_url", "")
	if not passport_url.is_empty():
		log.info("Redirecting user to passport URL at: " + str(passport_url))
		OS.shell_open(passport_url)
	else:
		log.error("Passport URL was empty when handling user login.")

	_start_session_check_timer()

func _start_session_check_timer() -> void:
	if continue_session_check:
		await get_tree().create_timer(5.0).timeout
		_on_check_session_timer_timeout()

func _on_check_session_timer_timeout() -> void:
	request("App.checkSession", {}, Callable(self, "_on_check_session"))
	_start_session_check_timer()

func _on_check_session(results: Dictionary) -> void:
	var result_data: Dictionary = results.get("result", {}).get("data", {})
	var session_obj: Dictionary = result_data.get("session", {})

	if "user" in session_obj and session_obj["user"]:
		_get_user_data(session_obj)
		continue_session_check = false

		if session_data.remember:
			# Handle 'remember' logic here
			pass
		log.info("User data successfully parsed from session! Finalizing authentification...")
	else:
		log.info("Could not parse valid user data from current Newgrounds session. Retrying in 5s...")

func _get_user_data(session_obj: Dictionary) -> void:
	## Update user resource with the data received
	var user: Dictionary = session_obj.get("user", null)
	user_data = NGUserData.new()
	user_data.id = user.get("id", 0)
	user_data.name = user.get("name", "")
	user_data.supporter = user.get("supporter", false)
	log.info("Saved App.startSession user data to resource: " + str(user_data))

	## Initialize and update user icons resource if available
	var icons: Dictionary = user.get("icons", {})
	user_icon_data = NGUserIconsData.new()
	user_icon_data.small = icons.get("large", "")
	user_icon_data.display_name = icons.get("medium", "")
	user_icon_data.is_supporter = icons.get("small", "")
	user_data.icons = user_icon_data
	log.info("Saved App.startSession user icon data to resource: " + str(user_icon_data))

func request(component: String, parameters: Dictionary, callable: Callable = Callable(), on_load_function: Variant = null) -> void:
	log.debug("Requesting component: {component} with parameters: {parameters}".format({"component": component, "parameters": JSON.stringify(parameters)}))

	var api_request: HTTPRequest = HTTPRequest.new()
	add_child(api_request)

	if callable:
		if on_load_function:
			api_request.request_completed.connect(_on_request_completed.bind(callable, on_load_function))
		else:
			api_request.request_completed.connect(_on_request_completed.bind(callable))

	var call_parameters: Dictionary = {"component": component, "parameters": parameters}
	log.debug("Raw call parameters: {params}".format({"params": JSON.stringify(call_parameters)}))

	var encrypted_call_parameters: String = encrypt_data(JSON.stringify(call_parameters), AES_KEY)
	var input_parameters: Dictionary = _prepare_input_parameters(encrypted_call_parameters)

	var request_data: String = "input=" + JSON.stringify(input_parameters).uri_encode()
	log.debug("Sending request payload: {request_data}".format({"request_data": request_data}))

	var error: int = api_request.request(GATEWAY_URI, ["Content-Type: application/x-www-form-urlencoded"], HTTPClient.METHOD_POST, request_data)
	if error != OK:
		log.error("HTTPRequest setup failed with error: {error}".format({"error": str(error)}))
		api_request.queue_free()
		return

	log.debug("HTTPRequest started for component: {component}".format({"component": component}))

func _prepare_input_parameters(encrypted_parameters: String) -> Dictionary:
	## Includes the session ID from the session_data resource if it's available
	var input_params: Dictionary = {
		"app_id": APP_ID,
		"call": {
			"secure": encrypted_parameters
		}
	}
	if session_data and session_data.id != "":
		input_params["session_id"] = session_data.id
	return input_params

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, callable: Callable, on_load_function: Variant = null) -> void:
	log.debug("Request completed. Result: {result}, code: {response_code}".format({"result": str(result), "response_code": str(response_code)}))
	if response_code != 200:
		log.error("HTTP Request failed with code: {response_code}".format({"response_code": str(response_code)}))
		return

	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	if error == OK:
		var response_data: Dictionary = json.data
		log.debug("Response parsed: {response_data}".format({"response_data": JSON.stringify(response_data)}))
		if typeof(response_data) == TYPE_DICTIONARY:
			if "error" in response_data:
				var error_data = response_data["error"]
				var error_code = error_data.get("code", "Unknown code")
				var error_message = error_data.get("message", "No error message")
				log.warn("Error Code: {code}, Error Message: {message}".format({"code": str(error_code), "message": error_message}))
			
			if callable:
				if on_load_function:
					callable.call(response_data, on_load_function)
				else:
					callable.call(response_data)
		else:
			log.error("Unexpected data type in JSON response")
	else:
		log.error("JSON Parse Error: {error_message} in {body} at line {error_line}".format({"error_message": json.get_error_message(), "body": body.get_string_from_utf8(), "error_line": str(json.get_error_line())}))

