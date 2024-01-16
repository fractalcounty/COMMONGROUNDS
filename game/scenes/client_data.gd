extends Resource
class_name ClientData

## OS/engine data
@export var os_name : String = OS.get_name() ## Windows, Linux, X11, HTML5, iOS, Server, etc.
@export var os_device_model_name : String = OS.get_model_name() ## iPhone10,6, GenericDevice, etc.
@export var os_locale : String = OS.get_locale() ## en_US, en_GB, fr_FR, fr_CA, etc.
@export var os_unique_id : String = OS.get_unique_id() ## 1234567890abcdef, 0987654321fedcba, etc.
@export var os_is_userfs_persistent: bool = OS.is_userfs_persistent()
@export var os_is_web : bool = OS.has_feature("web")

## Browser/web data
@export var web_is_newgrounds: bool = false ## true, false
@export var web_is_cookie_enabled: bool = false ## true, false
@export var web_user_agent: String = "" ## Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3, etc.
@export var web_time_zone: String = "" ## America/New_York, Europe/Paris, Asia/Tokyo, etc.

func _init() -> void:
	if OS.has_feature("web"):
		os_is_web = JavaScriptBridge.eval("navigator.onLine", true) as bool
		web_is_newgrounds = JavaScriptBridge.eval('new URLSearchParams(window.location.search).get("ngio_session_id")', true) != ""
		web_user_agent = JavaScriptBridge.eval("navigator.userAgent", true) as String
		web_time_zone = JavaScriptBridge.eval("Intl.DateTimeFormat().resolvedOptions().timeZone", true) as String
		web_is_cookie_enabled = JavaScriptBridge.eval("navigator.cookieEnabled", true) as bool

func to_dict() -> Dictionary:
	var dict : Dictionary = {}
	for property in get_property_list():
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			dict[property.name] = get(property.name)
	return dict
