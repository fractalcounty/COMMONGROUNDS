extends Object
class_name CommongroundsSession

var icon: String
var id: int
var px: float
var py: float
var supporter: bool
var username: String

func initialize(session_data: Dictionary) -> void:
	icon = session_data["icon"]
	id = session_data["id"]
	px = session_data["px"]
	py = session_data["py"]
	supporter = session_data["supporter"]
	username = session_data["username"]
