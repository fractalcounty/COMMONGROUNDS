extends Timer

var max_retries: int = 10
var current_retries : int = 0

# Called when the node enters the scene tree for the first time.
func keepalive(delay: float = 3) -> void:
	start(delay)

#func _process(_delta: float) -> void:
	#print(time_left)
	#current_retries += 1.0
	#if not current_retries == max_retries:
		#keepalive(keepalive_delay)
	#else:
		#Log.error("Too many attempts to login to newgrounds.")
