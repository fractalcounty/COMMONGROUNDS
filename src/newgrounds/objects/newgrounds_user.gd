extends Object
class_name NewgroundsUser

var icons : NewgroundsUserIcons
var id : int
var name : String
var supporter : bool

func initialize(user_data: Dictionary) -> void:
	Log.debug("initializing user data in NewgroundsUser object: " + str(user_data))
	if user_data["icons"]:
		icons = NewgroundsUserIcons.new()
		icons.call_deferred("initialize", user_data["icons"])
		name = user_data["name"]
		id = user_data["id"]
		supporter = user_data["supporter"]
		Log.debug("User initialized in NewgroundsUser.")
	else:
		Log.error("User data doesn't have icons")
