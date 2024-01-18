extends Object
class_name NewgroundsSession

var expired : bool
var id : String
var passport_url : String
var remember : bool

var user: NewgroundsUser

func initialize(session_data: Dictionary) -> void:
	expired = session_data["expired"]
	id = session_data["id"]
	if session_data.has("passport_url"):
		passport_url = session_data["passport_url"]
	remember = session_data["remember"]
	
	if session_data.has("user") and session_data["user"]:
		Log.debug("NewgroundsSession: NewgroundsUser object found in Newgrounds session_data response.")
		user = NewgroundsUser.new()
		user.call_deferred("initialize", session_data["user"])
	else:
		Log.debug("NewgroundsSession: No NewgroundsUser object found in Newgrounds session_data response.")
