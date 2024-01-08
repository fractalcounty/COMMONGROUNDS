extends Node
## Newgrounds.io autoload helper script for Godot 4.0
##
## Provides various methods to call the Newgrounds.io
## API from your scripts with detailed logging
##
## @tutorial(Components):	http://www.newgrounds.io/help/components/
## @tutorial(Objects):		https://www.newgrounds.io/help/objects/

signal request_completed(response_data : Dictionary)
signal logged_in(user: UserData)

const APP_ID : String = "57486:i7TJksdI" ## Game app ID
const GATEWAY_URI: String = "https://newgrounds.io/gateway_v3.php"

var user : UserData

#region Newgrounds login authorization
## Step 1: Initialize login auth. This is called in the main Game.gd script via '_load_ng_auth()' during the startup sequence
func login() -> void:
	Log.debug("Attempting to authorize Newgrounds session...", self)
	request("App.checkSession", {}, Callable(self, "_on_check_session"))

## Step 2: Parse the checkSession response and ensures validity before continuing
func _on_check_session(response_data: Dictionary) -> void:
	# Check if Newgrounds session response is null or empty
	var session : Dictionary = response_data.get("session", {})
	if not session or session.is_empty(): ## Check if session is invalid
		Log.error("Error: Session is empty or does not exist", self)
		
	# Check if Newgrounds session response is expired
	var expired: bool = session.get("expired", true)
	if expired:
		Log.warning("Warning: NG user session expired. Re-verifying...", self)
	
	# Other error checking is likely required here
	
	## Finally, checks if user is logged in to Newgrounds
	var user_dict: Dictionary = session.get("user", {})
	if user_dict:
		_keep_session_alive()
		_serialize_login(user_dict)
	else:
		Log.warning("User is not logged into NG.", self)

func _keep_session_alive() -> void:
	await get_tree().create_timer(300.0).timeout ## Keep the session alive by pinging the server every 5 minutes
	# Then use 'Gateway.ping' here to keep alive. Idk how to do this rn lol
	_keep_session_alive() # Loops recursively

## Step 3: Save the user data to the game itself (and eventually Commongrounds server)
## It's saved as a serialized custom resource (NGUserData), see ng_user_data.gd for the template
func _serialize_login(user_dict: Dictionary) -> void:
	Log.debug("Serializing Newgrounds user data...", self)
	
	var _user_data : UserData = UserData.new()
	_user_data.id = user_dict.get("id", 0)
	_user_data.display_name = user_dict.get("name", "")
	_user_data.is_supporter = user_dict.get("supporter", false)
	user = _user_data
	## This can now be accessed globally. For example:
	## 'nametag.text = NG.user_data.display_name'
	
	logged_in.emit()
	Log.debug("User is logged into Newgrounds as:" + str(user.display_name), self)
#endregion

#region Request logic
func request(component: String, parameters: Dictionary, callable: Callable = Callable(), on_load_function: Variant = null) -> void:
	if "127.0.0.1" in IP.get_local_addresses() or "::1" in IP.get_local_addresses():
		Log.warn("Warning: hostname is 'localhost'. Please test the game on Newgrounds or launch with the SKIP_NG_AUTH parameter in Game.gd.", self)
	
	var request_parameters : Dictionary = _construct_request_parameters(component, parameters)
	if request_parameters.is_empty():
		Log.error("Error: Invalid request parameters:" + str(parameters) + " of component: " + component, self)
		return
	
	_push_request(request_parameters, callable, on_load_function)

func _construct_request_parameters(component: String, parameters: Dictionary) -> Dictionary:
	var call_parameters: Dictionary = {
		"component": component,
		"parameters": parameters,
	}
	
	var json_string : String = JSON.stringify(call_parameters)
	var secure_encoding : String = _encrypt_data(json_string)
	var session_id : String = _get_ngio_session_id()
	
	if session_id.is_empty():
		Log.error("Error: Session ID is missing", self)
		return Dictionary()

	return {
		"app_id": APP_ID,
		"session_id": session_id,
		"execute": secure_encoding,
	}

func _push_request(input_parameters: Dictionary, callable: Callable, on_load_function: Variant) -> void:	
	var callable_for_completed_request : Callable = Callable(self, "_on_request_completed").bind(callable, on_load_function)
	var ngio_request: HTTPRequest = HTTPRequest.new()
	add_child(ngio_request) 
	
	if not ngio_request.request_completed.is_connected(callable_for_completed_request):
		ngio_request.request_completed.connect(callable_for_completed_request)

	# Send the final request payload
	var request_data : String = JSON.stringify(input_parameters)
	ngio_request.request(
		GATEWAY_URI,
		["Content-Type: application/x-www-form-urlencoded"],
		HTTPClient.METHOD_POST,
		"input=" + request_data.uri_encode()
	)


func _get_ngio_session_id() -> String:
	var js_code := 'var urlParams = new URLSearchParams(window.location.search);' + 'urlParams.get("ngio_session_id");'
	var result : Variant  = JavaScriptBridge.eval(js_code, true)

	if result is String and result != "":
		return result
	else:
		Log.error("Error getting Newgrounds.io Session ID. Possible connection issue?", self)
		return ""

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

	# Call the provided callable if it exists
	if on_load_function:
		callable.call(response_data, on_load_function)
	else:
		callable.call(response_data)

	emit_signal("request_completed", response_data)
#endregion

#region Response processing
func _http_result_processing(result: int) -> bool:
	if result != HTTPRequest.RESULT_SUCCESS:
		Log.error("Error: HTTPRequest failed with result code: %d" % result, self)
		return false
	return true


func _http_response_processing(response_code: int, headers: PackedStringArray, body: PackedByteArray) -> bool:
	if response_code != 200:
		var error_message : String = "Error: HTTP Request Failed: Code %s\nHeaders: %s\nBody: %s" % [response_code, '.'.join(headers), body.get_string_from_utf8()]
		Log.error(error_message, self)
		return false
	return true


func _parse_json_response(body: PackedByteArray) -> Dictionary:
	var json_parser : JSON = JSON.new()
	var error : Error = json_parser.parse(body.get_string_from_utf8())
	if error != OK:
		Log.error("JSON Parse Error: %s at line %d" % [json_parser.get_error_message(), json_parser.get_error_line()], self)
		return {}
	return json_parser.data


func _response_data_error_check(response_data: Dictionary, response_code: int, headers: PackedStringArray) -> bool:
	if response_data.has("error"):
		var detailed_error : String = "Error in response: %s\nRaw JSON: %s\nResponse Code: %d\nHeaders: %s" % [str(response_data["error"]), JSON.stringify(response_data), response_code, '.'.join(headers)]
		Log.error(detailed_error, self)
		return false
	return true
#endregion

#region Encryption crap
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
	var key : PackedByteArray = Marshalls.base64_to_raw("4tWX2jGEhqoohsboJ5e04Q==")  #TODO: Load from secure env. var in production
	if key.size() != 16 and key.size() != 32:
		Log.error("Key length is not 16 or 32 bytes. Actual length: " + str(key.size()), self)
		return ""
	var iv : PackedByteArray = _generate_random_iv(16)

	var data_bytes : PackedByteArray = data.to_utf8_buffer()
	data_bytes = _pad_buffer(data_bytes)

	aes.start(AESContext.MODE_CBC_ENCRYPT, key, iv)
	var encrypted : PackedByteArray = aes.update(data_bytes)
	aes.finish()

	var combined : PackedByteArray = iv + encrypted
	return Marshalls.raw_to_base64(combined)
#endregion

#region Cloud saving
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
#endregion
