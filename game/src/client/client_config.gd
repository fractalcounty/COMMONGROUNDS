extends Object
class_name ClientConfig
## An all-purpose settings script that handles the
## loading, unloading, and saving of a settings.cfg.
##
## If a settings.cfg file does not exist, this script
## creates one using default project settings.
## Use _default_settings() to define new defaults.

static var config : ConfigFile = ConfigFile.new()
static var settings_path : String = "user://settings.cfg"
static var data_persistence_error_message : String = "User file system is not persistent. Data will not be saved correctly."

## Dictionary of default settings using lambdas.
## Each setting is represented by a key-value pair, where the
## key is the setting path and the value is a lambda function that returns the default value
static var _default_settings : Dictionary = {
	"Video/resolution_w": func() -> int: return ProjectSettings.get_setting("display/window/size/viewport_width"),
	"Video/resolution_h": func() -> int: return ProjectSettings.get_setting("display/window/size/viewport_height"),
	"Video/vsync": func() -> int: return ProjectSettings.get_setting("display/window/vsync/vsync_mode"),
	"Video/window_mode": func() -> int: return ProjectSettings.get_setting("display/window/size/mode"),
	"Video/max_fps": func() -> int: return ProjectSettings.get_setting("application/run/max_fps"),
	"Audio/master_volume": func() -> float: return AudioServer.get_bus_volume_db(0),
	"Audio/sfx_volume": func() -> float: return AudioServer.get_bus_volume_db(1),
	"Audio/music_volume": func() -> float: return AudioServer.get_bus_volume_db(2),
	"Application/skip_splash_screen": func() -> bool: return ProjectSettings.get_setting("application/run/skip_splash_screen"),
	"Application/debug_mode": func() -> bool: return ProjectSettings.get_setting("application/run/debug_mode")
}

func _init() -> void:
	load_settings()

static func to_dict() -> Dictionary:
		var dict = {}
		for section in config.get_sections():
			dict[section] = {}
			for key in config.get_section_keys(section):
				dict[section][key] = config.get_value(section, key)
		return dict

static func to_text() -> String:
	var encoded_settings : String = config.encode_to_text()
	if encoded_settings.is_empty():
		Log.err("Error on ConfigFile.to_text(): Encoded settings are empty.")
		return ""
	return encoded_settings

## Loads the client settings from the configuration file.
## If the file fails to load, default values are used.
## Returns an Error indicating the success or failure of the operation.
static func load_settings() -> Error:
	Log.err_cond_false(OS.is_userfs_persistent(), data_persistence_error_message)
	_add_custom_project_setting("application/run/skip_splash_screen", false, TYPE_BOOL)
	_add_custom_project_setting("application/run/debug_mode", false, TYPE_BOOL)
	var err : Error = config.load(settings_path)
	if err != OK:
		Log.warn("Could not load settings from path: " + str(settings_path) + ". Reverting to default values.")
		_create_settings_file_using_defaults()
	else:
		Log.info("Successfully loaded client settings from: " + settings_path)
	return err

## Saves the current settings to the configuration file.
## Returns an Error indicating the success or failure of the operation.
static func save_settings() -> Error:
	Log.err_cond_false(OS.is_userfs_persistent(), data_persistence_error_message)
	var err : Error = config.save(settings_path)
	Log.err_cond_not_ok(err, "Error saving settings to: " + settings_path + ".")
	return err

## Updates a specific setting in the configuration file.
## Returns an Error indicating the success or failure of the operation.
static func update_setting(section: String, key: String, value: Variant) -> Error:
	Log.err_cond_false(OS.is_userfs_persistent(), data_persistence_error_message)
	config.set_value(section, key, value)
	var err : Error = save_settings()
	Log.err_cond_not_ok(err, "Error updating settings to: " + settings_path + ".")
	return err

## Resets all settings to their default values.
## Returns an Error indicating the success or failure of the operation.
static func reset_to_defaults() -> Error:
	var err : Error = FAILED
	for setting_path : String in _default_settings.keys():
		var section_key : Array = setting_path.split("/")
		err = reset_setting_to_default(section_key[0], section_key[1])
		Log.err_cond_not_ok(err, "Error resetting setting '" + setting_path + " to default value.")
		return err
	Log.err_cond_not_ok(err, "Error resetting settings to default values at " + str(settings_path))
	return err


## Resets a specific setting to its default value.
## Returns an Error indicating the success or failure of the operation.
static func reset_setting_to_default(section: String, key: String) -> Error:
	var err : Error = ERR_DOES_NOT_EXIST
	var setting_path : String = section + "/" + key
	if setting_path in _default_settings:
		config.set_value(section, key, _default_settings[setting_path].call())
		err = save_settings()
		Log.err_cond_not_ok(err, "Error resetting setting to default: " + key + " in  section " + section)
		return err
	else:
		Log.err_cond_not_ok(err, "Error resetting setting to default: " + key + " in  section " + section)
		return err

## Creates the settings file using default values for each setting.
## This function is called when the settings file fails to load.
static func _create_settings_file_using_defaults() -> void:
	for setting in _default_settings.keys():
		var section_key = setting.split("/")
		config.set_value(section_key[0], section_key[1], _default_settings[setting].call())
	save_settings()

## Adds a custom project setting to the ProjectSettings.
## If the setting already exists, it is not added.
static func _add_custom_project_setting(name: String, default_value: Variant, type: int, hint: int = PROPERTY_HINT_NONE, hint_string: String = "") -> void:
	if ProjectSettings.has_setting(name):
		Log.debug("Project setting already exists: " + name)
		return

	var setting_info: Dictionary = {
		"name": name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string
	}

	ProjectSettings.set_setting(name, default_value)
	ProjectSettings.add_property_info(setting_info)
	ProjectSettings.set_initial_value(name, default_value)
	Log.info("Adding project setting: " + name + " with value: " + str(default_value))
