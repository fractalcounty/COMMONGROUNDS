extends Object
class_name NewgroundsUserIcons

var large : String
var medium : String
var small : String

func initialize(icons_data: Dictionary) -> void:
	large = icons_data["large"]
	medium = icons_data["medium"]
	small = icons_data["small"]
