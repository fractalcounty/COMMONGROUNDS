@icon("res://resources/textures/icons/Config.svg")
extends Node
class_name ClientConfig
## An all-purpose config script that handles the
## loading, unloading, and saving of a config.cfg.
##
## If a config.cfg file does not exist, this script
## creates one using default project config below.

var config_file : ConfigFile
var config_path : String = "user://config.cfg"
var data_persistence_error : String = "User file system is not persistent. Data will not be saved or loaded correctly."

var default_config : Dictionary = {
	"Application": {
		"debug_mode": false,
		"skip_splash_screen": false
	},
	"Video": {
		"max_fps": 0,
		"resolution": Vector2i(1920, 1080),
		"vsync_mode": 1,
		"window_mode": 0
	},
	"Audio": {
		"master_volume": 1.0,
		"music_volume": 1.0,
		"sfx_volume": 1.0
	}
}


func _init() -> void:
	config_file = ConfigFile.new()
	_load()

func _ready() -> void:
	Global.config = self
	
## Saves the current config to the configuration file.
## Saves any changes to the current ConfigFile onto the disk.
## Returns an Error indicating the success or failure of the operation.
func save() -> Error:
	Log.err_cond_false(OS.is_userfs_persistent(), data_persistence_error)
	var err : Error = config_file.save(config_path)
	Log.err_cond_not_ok(err, "Error saving config to: " + config_path + ".")
	return err

## Updates a specific entry in the configuration file in memory.
## Run save() after making changes to actually save it to disk.
## Returns an Error indicating the success or failure of the operation.
func set_value(section: String, key: String, value: Variant) -> Error:
	Log.err_cond_false(OS.is_userfs_persistent(), data_persistence_error)
	config_file.set_value(section, key, value)
	var err : Error = save()
	Log.err_cond_not_ok(err, "Error updating config to: " + config_path + ".")
	return err

## Resets a specific setting to its default value in memory.
## Run save() after making changes to actually save it to disk.
## Returns an Error indicating the success or failure of the operation.
func reset(section: String, key: String) -> Error:
	var err : Error = ERR_DOES_NOT_EXIST
	var default_value : Variant = _get_default_value(section, key)
	if default_value != null:
		config_file.set_value(section, key, default_value)
		err = save()
	Log.err_cond_not_ok(err, "Error resetting setting to default: " + key + " in  section " + section)
	return err

func is_debug_mode() -> bool:
	# Check if the section and key exist in the config file
	if config_file.has_section("Application") and config_file.has_section_key("Application", "debug_mode"):
		# Retrieve and return the value of debug_mode
		return config_file.get_value("Application", "debug_mode", false)
	else:
		# If the section/key does not exist, log an error and return a default value (false)
		Log.warn("Debug mode setting not found in config. Returning default value: false.")
		return false

## Returns the entire current config .cfg file as a dictionary
func to_dict() -> Dictionary:
		var dict : Dictionary = {}
		for section in config_file.get_sections():
			dict[section] = {}
			for key in config_file.get_section_keys(section):
				dict[section][key] = config_file.get_value(section, key)
		return dict

## Returns the entire current config .cfg file as a text string
func to_text() -> String:
	var encoded_config : String = config_file.encode_to_text()
	if encoded_config.is_empty():
		Log.err("Error on ConfigFile.to_text(): Encoded config are empty.")
		return ""
	return encoded_config

func _get_default_value(section: String, key: String) -> Variant:
	## Returns the default value for a given setting.
	return null

func _load() -> Error:
	Log.err_cond_false(OS.is_userfs_persistent(), data_persistence_error)
	
	# Attempt to load the config file
	var err : Error = config_file.load(config_path)
	
	#  Check if loading was successful
	if err != OK:
		Log.warn("ERR_FILE_CANT_OPEN: " + "Could not load config file from path: " + str(config_path) + ". Creating config.cfg with default values.")
		call_deferred("_create_config_file_using_defaults")
	else:
		Log.info("Successfully loaded client config from: " + config_path)
		Global.client_config_file_ready.emit(config_file)
	return err


func _create_config_file_using_defaults() -> void:
	## Iterate through each section in the default config dictionary
	for section in default_config.keys():
		var default_config: Dictionary = default_config[section]
		## Iterate through each key-value pair in the section
		for key in default_config.keys():
			var value: Variant = default_config[key]
			## Set the value in the ConfigFile
			config_file.set_value(section, key, value)

	## Save the ConfigFile to the specified path
	var error: Error = config_file.save(config_path)
	if error != OK:
		Log.err("Failed to save config file: " + str(error))
	else:
		Log.info("Config file created with default values.")

