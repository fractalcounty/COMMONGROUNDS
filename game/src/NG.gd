extends Node
## Newgrounds.io autoload helper script
##
## Provides various methods to call the
## Newgrounds.io API from your scripts
##
## @tutorial(Components):	http://www.newgrounds.io/help/components/
## @tutorial(Objects):		https://www.newgrounds.io/help/objects/

signal request_completed(response_data : Dictionary)

#WARNING: These need to be loaded externally from a secure source or env. variable in actual production
const APP_ID : String = "57486:ERDC0aUO" ## Gane app ID
const GATEWAY_URI: String = "https://newgrounds.io/gateway_v3.php"

var newgroundsio_request: HTTPRequest

#region Encryption bull crap

func _generate_random_iv(size: int) -> PackedByteArray:
	var crypto : Crypto = Crypto.new()
	return crypto.generate_random_bytes(size)

func _pad_buffer(data: PackedByteArray) -> PackedByteArray:
	var padding_needed : int = 16 - data.size() % 16
	if padding_needed == 16:
		return data
	for i in range(padding_needed):
		data.push_back(0)
	return data

func _encrypt_data(data: String) -> String:
	var aes : AESContext = AESContext.new()
	var key : PackedByteArray = Marshalls.base64_to_raw("7WUH8Ts8QfAple+rMlyPIg==")  #TODO: Load from secure env. var in production
	if key.size() != 16 and key.size() != 32:
		Log.error("Key length is not 16 or 32 bytes. Actual length: " + str(key.size()), self)
		return ""
	var iv : PackedByteArray = _generate_random_iv(16)  # Generate a new IV for each call

	var data_bytes : PackedByteArray = data.to_utf8_buffer()
	data_bytes = _pad_buffer(data_bytes)  # Ensure data is a multiple of 16 bytes

	aes.start(AESContext.MODE_CBC_ENCRYPT, key, iv)
	var encrypted : PackedByteArray = aes.update(data_bytes)
	aes.finish()

	# Combine IV and encrypted data, then convert to Base64
	var combined : PackedByteArray = iv + encrypted
	return Marshalls.raw_to_base64(combined)
#endregion

## Initializes, validates and prepares the request parameters
func request(component: String, parameters: Dictionary, callable: Callable = Callable(), on_load_function: Variant = null) -> void:
	var input_parameters : Dictionary = _request_params(component, parameters)
	if input_parameters.is_empty(): ## If the parameter preperation fails
		Log.error("Invalid request parameters:" + str(parameters) + " of component: " + component, self)
		return
	_perform_request(input_parameters, callable, on_load_function)

## Constructs the request() parameters
func _request_params(component: String, parameters: Dictionary) -> Dictionary:
	var call_parameters: Dictionary = {
		"component": component,
		"parameters": parameters,
	}
	
	var json_string : String = JSON.stringify(call_parameters)
	var secure_encoding : String = _encrypt_data(json_string)

	var session_id : String = get_session_id()
	if session_id.is_empty():
		Log.error("Session ID is missing", self)
		return Dictionary()

	return {
		"app_id": APP_ID,
		"session_id": session_id,
		"execute": secure_encoding,
	}

## Finally go through with API request if we make it this far
func _perform_request(input_parameters: Dictionary, callable: Callable, on_load_function: Variant) -> void:
	## Just kidding. One more check to ensure HTTPRequest node exists and is configured properly
	if not newgroundsio_request or not is_instance_valid(newgroundsio_request):
		newgroundsio_request = HTTPRequest.new()
		add_child(newgroundsio_request)

	## Create a Callable for the _on_request_completed function
	var callable_for_request_completed : Callable = Callable(self, "_on_request_completed").bind(callable, on_load_function)
	## Check if the signal is already connected to prevent multiple connections
	if not newgroundsio_request.request_completed.is_connected(callable_for_request_completed):
		newgroundsio_request.request_completed.connect(callable_for_request_completed)
	
	## Okay, for real, this perform the HTTP request
	var request_data : String = JSON.stringify(input_parameters)
	newgroundsio_request.request(
		GATEWAY_URI,
		["Content-Type: application/x-www-form-urlencoded"],
		HTTPClient.METHOD_POST,
		"input=" + request_data.uri_encode()
	)

func get_session_id() -> String:
	var js_code := 'var urlParams = new URLSearchParams(window.location.search);' + 'urlParams.get("ngio_session_id");'
	var result : Variant  = JavaScriptBridge.eval(js_code, true)

	if result is String and result != "":
		return result
	else:
		## Handle the case where the session ID is not found or the JavaScriptBridge is not working
		Log.error("Session ID not found or JavaScriptBridge not available.", self)
		return ""

## On request completed callback
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, callable: Callable, on_load_function: Variant = null) -> void:
	if not _http_result_processing(result):
		return
	if not _http_response_processing(response_code, headers, body):
		return
	var response_data : Dictionary = _parse_json_response(body)
	if response_data == null:
		return
	if not _response_data_error_check(response_data, response_code, headers):
		return

	## Call the provided callable if it exists
	if on_load_function:
		callable.call(response_data, on_load_function)
	else:
		callable.call(response_data)

	emit_signal("request_completed", response_data)

#region Response processing
## HTTP Result
func _http_result_processing(result: int) -> bool:
	if result != HTTPRequest.RESULT_SUCCESS:
		Log.error("HTTPRequest failed with result code: %d" % result, self)
		return false
	return true

## HTTP Response
func _http_response_processing(response_code: int, headers: PackedStringArray, body: PackedByteArray) -> bool:
	if response_code != 200:
		var error_message : String = "HTTP Request Failed: Code %s\nHeaders: %s\nBody: %s" % [response_code, '.'.join(headers), body.get_string_from_utf8()]
		Log.error(error_message, self)
		return false
	return true

## JSON response
func _parse_json_response(body: PackedByteArray) -> Dictionary:
	var json_parser : JSON = JSON.new()
	var error : Error = json_parser.parse(body.get_string_from_utf8())
	if error != OK:
		Log.error("JSON Parse Error: %s at line %d" % [json_parser.get_error_message(), json_parser.get_error_line()], self)
		return {}
	return json_parser.data

## Data error checking
func _response_data_error_check(response_data: Dictionary, response_code: int, headers: PackedStringArray) -> bool:
	if response_data.has("error"):
		var detailed_error : String = "Error in response: %s\nRaw JSON: %s\nResponse Code: %d\nHeaders: %s" % [str(response_data["error"]), JSON.stringify(response_data), response_code, '.'.join(headers)]
		Log.error(detailed_error, self)
		return false
	return true
#endregion

#func request(component: String, parameters: Dictionary, callable = null, on_load_function = null) -> void:
	#
	#Log.debug("Attempting to request '%s' with parameters '%s'" % [component, str(parameters)], self)
	#
	#newgroundsio_request = HTTPRequest.new()
	#add_child(newgroundsio_request)
#
	#if callable:
		#if on_load_function:
			#newgroundsio_request.request_completed.connect(_request_completed.bind(callable, on_load_function))
		#else:
			#newgroundsio_request.request_completed.connect(_request_completed.bind(callable))
#
	#var call_parameters: Dictionary = {
		#"component": component,
		#"parameters": parameters,
	#}
#
	### Encrypt with CryptoJS
	### Uses a helper script (cryptojs.gd) to handle all this nonsense
	#var secure_encoding: String = CryptoJS.encrypt(JSON.stringify(call_parameters), AES_KEY)
	#var input_parameters: Dictionary = {
		#"app_id": APP_ID,
		#"session_id": str(JavaScriptBridge.eval(
			#'var urlParams = new URLSearchParams(window.location.search);' +
			#'urlParams.get("ngio_session_id");',
			#true
		#)),
		#"call": {
			#"secure": secure_encoding,
		#}
	#}
#
	#newgroundsio_request.request(
		#gateway_uri,
		#["Content-Type: application/x-www-form-urlencoded"],
		#HTTPClient.METHOD_POST,
		#"input=" + JSON.stringify(input_parameters).uri_encode()
	#)

#func cloud_save(data:Dictionary, slot:int = 1, callable:Callable = Callable(self, "_show_cloud_save_results")):
	#var stringified_data = JSON.stringify(data)
	#stringified_data = stringified_data.replace('"', '<<<doublequote>>>')
	#stringified_data = stringified_data.replace("'", '<<<singlequote>>>')
	#request("CloudSave.setData", {"data": stringified_data, "id": slot}, callable)
#
#func _show_cloud_save_results(results):
	#if show_cloudsave_results:
		#Log.debug("Results from cloud save request: " + str(results), self)
#
#
#func cloud_load(on_load_function:Callable, slot:int = 1):
	#if show_cloudsave_results:
		#Log.debug("Sending cloud load request for slot " + str(slot), self)
	#request("CloudSave.loadSlot", {"id": slot}, Callable(self, "_handle_single_cloud_load_results"), on_load_function)
#
#func _handle_single_cloud_load_results(results, on_load_function:Callable):
	#var load_http_request = HTTPRequest.new()
	#if show_cloudsave_results:
		#Log.debug("Results from single slot cloud load request (not the actual data yet): " + str(results), self)
	#if not results["success"]:
		#on_load_function.call(null)
		#return
	#if results["result"]["data"]["slot"]["url"] == null:
		#on_load_function.call(null)
		#return
	#add_child(load_http_request)
	#load_http_request.request_completed.connect(_handle_single_cloud_load_data.bind(on_load_function))
	#load_http_request.request(results["result"]["data"]["slot"]["url"])
#
#func _handle_single_cloud_load_data(result, response_code, headers, body, on_load_function:Callable):
	#var stringified_data:String = body.get_string_from_ascii()
	#stringified_data = stringified_data.replace('<<<doublequote>>>', '"')
	#stringified_data = stringified_data.replace('<<<singlequote>>>', "'")
	#if show_cloudsave_results:
		#Log.debug("Loaded object: " + JSON.parse_string(stringified_data), self)
	#on_load_function.call(JSON.parse_string(stringified_data))
#
#
#func cloud_load_all(on_load_function:Callable):
	#if show_cloudsave_results:
		#Log.debug("Sending cloud load request for all slots", self)
	#request("CloudSave.loadSlots", {}, Callable(self, "_handle_multiple_cloud_load_results"), on_load_function)
#
#func _handle_multiple_cloud_load_results(results, on_load_function:Callable):
	#var load_http_request
	#if show_cloudsave_results:
		#Log.debug("Results from all slot cloud load request (not the actual data yet): " + str(results), self)
	#if not results["success"]:
		#on_load_function.call(null)
		#return
	#for slot in results["result"]["data"]["slots"]:
		#if slot["url"] == null:
			#on_load_function.call(slot["id"], null)
		#else:
			#load_http_request = HTTPRequest.new()
			#add_child(load_http_request)
			#load_http_request.request_completed.connect(_handle_multiple_cloud_load_data.bind(on_load_function, slot["id"]))
			#load_http_request.request(slot["url"])
#
#func _handle_multiple_cloud_load_data(result, response_code, headers, body, on_load_function:Callable, slot_number):
	#var stringified_data:String = body.get_string_from_ascii()
	#stringified_data = stringified_data.replace('<<<doublequote>>>', '"')
	#stringified_data = stringified_data.replace('<<<singlequote>>>', "'")
	#if show_cloudsave_results:
		#Log.debug("Loaded from slot #" + str(slot_number) + ": " + JSON.parse_string(stringified_data), self)
	#on_load_function.call(slot_number, JSON.parse_string(stringified_data))
