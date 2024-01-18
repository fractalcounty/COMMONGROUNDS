extends Node2D

signal ok
#
#@onready var camera : Camera2DPlus = $Camera2DPlus
#@onready var local_player_node : Player = $Player
#@onready var window: Window = get_window()
#@onready var chat : PopupPanel = $PopupPanel
#var user_scene: PackedScene = preload("res://client/commongrounds/user/User.tscn")
#
#@onready var username : String = get_parent().session.user.name
#@onready var id : int = get_parent().session.user.id
#@onready var icon : String = get_parent().session.user.icons.large
#@onready var supporter : bool = get_parent().session.user.supporter
#
#const host = "commongrounds-57371-default-rtdb.firebaseio.com"
#const base_url = "https://%s" % host
#var is_initialized: bool = false
#
#
#@onready var http: HTTPRequest = $HTTPRequest
#
#var connected_players = {}
#var player_nodes = {}
#
#var local_player = {}
#var local_player_buffer = []
#
#@onready var _log : LogStream = LogStream.new("Commongrounds", Log.LogLevel.DEBUG)
#
#func spawn_user() -> User:
	#var user : User = user_scene.instantiate() as User
	#add_child(user)
	#return user
#
#
#func _ready() -> void:
	#set_process(false)
#
#func initialize() -> void:
	#if is_initialized:
		#return
	#is_initialized = true
	#
	#set_process(true)
	#local_player_node.set_player_name(username)
	#
	#get_tree().set_auto_accept_quit(false)
	#
	#await connect_player()
	#start_player_stream()
	#start_write_player()
#
#func _process(_delta):
	#var new_local_player : Dictionary = {
		#"username": username,
		#"id": id,
		#"icon": icon,
		#"supporter": supporter,
		#"px": local_player_node.position.x,
		#"py": local_player_node.position.y,
	#}
	#if new_local_player.hash() != local_player.hash():
		#local_player = new_local_player
		#local_player_buffer.append(new_local_player)
#
#func _notification(what):
	#if (what == NOTIFICATION_WM_CLOSE_REQUEST):
		#await disconnect_player()
		#get_tree().quit()
#
#func start_write_player():
	#while true:
		#if local_player_buffer.size() > 0:
			#var curr_player_data = local_player_buffer[local_player_buffer.size() -1]
			#local_player_buffer.clear()
			#await write_player(id, curr_player_data)
		#await get_tree().process_frame
#
#func connect_player():
	#_log.info("Initializing player: " + username + " (id: " + str(id) + ")")
	#var player = {
		#"username": username,
		#"id": id
	#}
	#await write_player(id, player)
	#_log.info("Player initialized!")
#
#func disconnect_player():
	#_log.info("Disconnecting player: " + username + "(" + str(id) + ")")
	#await delete_player(id)
	#_log.info("Player disconnected!")
	#
#func start_player_stream():
	#_log.info("Connecting to host...")
	#var tcp = StreamPeerTCP.new()
	#var err = tcp.connect_to_host(host, 443)
	#if err != OK:
		#_log.warn("Error connecting to host: " + error_string(err))
	#else:
		#_log.info("Connected to host successfully.")
#
	#
	#while tcp.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		#tcp.poll()
		#await get_tree().process_frame
	#_log.info("Conected: ", tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED)
#
	#_log.info("Connecting to stream...")
	#var stream = StreamPeerTLS.new()
	#err = stream.connect_to_stream(tcp, host, TLSOptions.client())
	#_log.warn("Error connecting to stream: " + error_string(err)) # Make sure connection is OK.
	#
	#while true:
		#stream.poll()
		#var status = stream.get_status()
		#_log.debug("stream status: ", status)
		#if status == StreamPeerTLS.STATUS_CONNECTED:
			#break
		#await get_tree().create_timer(0.1).timeout
	#
	#var request = "GET https://%s/connected_players.json HTTP/1.1\n" % host
	#request += "Host: %s\n" % host
	#request += "Accept: text/event-stream\n\n"
	#stream.put_data(request.to_utf8_buffer())
	#
	#var initialRequest = false
	#while true:
		## Poll the stream to ensure connection is valid and check for availalbe bytes.
		#stream.poll()
		#var available_bytes: int = stream.get_available_bytes()
		#if available_bytes > 0:
			#var data: Array = stream.get_partial_data(available_bytes)
			## Check for read error.
			#if data[0] != OK:
				#_log.err("Error getting data from stream: ", data[0])
			#else:
				#var response : String = data[1].get_string_from_utf8()
				#if !initialRequest:
					#if "HTTP/1.1 200 OK" not in response:
						#_log.err("Non-ok status code received from stream request: " + response)
					#else:
						#_log.info("Stream started listening!")
						#await load_all_players()
				#else :
					#process_event(response)
				#
				#initialRequest = true
		#await get_tree().process_frame
		#ok.emit()
	#
	#stream.disconnect_from_stream()
	#tcp.disconnect_from_host()
#
#func process_event(event_data: String):
	#var lines = event_data.replace(" ", "").split("\n")
	#var event = lines[0].split("event:")[1]
	#var data = lines[1].split("data:")[1]
	#var json = JSON.new()
	#var error = json.parse(data)
	#
	#if error != OK:
		#_log.error("JSON Parse Error: %s in %s at line %d" % [json.get_error_message(), data, json.get_error_line()])
		#return
	#
	#var jsonData : Variant = json.get_data()
	#var jsonDataString = JSON.stringify(jsonData)
	#
	#var prettified_data : String = JSONBeautifier.beautify_json(jsonDataString)
	#_log.debug("Received data: %s" % prettified_data)  # Print beautified json to console
#
	#if event != "put":
		#_log.warn("unhandled event '%s' with data '%s'" % [event, prettified_data])
	#else:
		#var path = jsonData["path"]
		#var recieved_id = path.split("/")[1]
		#
		#if recieved_id == null:
			#return
		#
		## Ignore updates for the local player
		#if recieved_id == str(id):
			#return
		#
		#if recieved_id not in connected_players:
			#_log.info(username + " (" + str(recieved_id) + ")" + " joined the COMMONGROUNDS.")
		#
		#if recieved_id in connected_players and jsonData["data"] == null:
			#_log.info(username + " (" + str(recieved_id) + ")" + " left the COMMONGROUNDS.")
			#connected_players.erase(recieved_id)
		#else:
			#connected_players[recieved_id] = jsonData["data"]
		#sync_players()
#
#
#func sync_players():
	#for id in connected_players:
		#if id not in player_nodes:
			#var node: User = spawn_user()
			#player_nodes[id] = node
		#
		#var pd = connected_players[id]
		#
		#if pd is Dictionary:
			#if "px" in pd and "py" in pd:
				#player_nodes[id].set_target_position(Vector2(pd["px"], pd["py"]))
			#
			#if "icon" in pd:
				#player_nodes[id].set_icon(pd["icon"])
			#
			#if "supporter" in pd:
				#player_nodes[id].set_supporter(pd["supporter"])
			#
			#if "username" in pd:
				#player_nodes[id].set_player_name(pd["username"])
			#else:
				#player_nodes[id].set_player_name("Unknown")  # Or any default name you prefer
		#
	#for id in player_nodes:
		#if id not in connected_players:
			#player_nodes[id].queue_free()
			#player_nodes.erase(id)
			#break
#
#func delete_player(player_id: int):
	#local_player_buffer.clear()
	#http.cancel_request()
	#http.request("%s/connected_players/%s.json" % [base_url, player_id],
		#[], HTTPClient.METHOD_DELETE)
	#var _response = await http.request_completed
#
#func write_player(player_id: int, data: Dictionary):
	#http.request("%s/connected_players/%s.json" % [base_url, player_id],
		#[], HTTPClient.METHOD_PUT, JSON.stringify(data))
	#var _response = await http.request_completed
#
#func load_all_players():
	#var req : String = "%s/connected_players.json" % base_url
	#http.request(req)
	#var response = await http.request_completed
	#var json : JSON = JSON.new()
	#json.parse(response[3].get_string_from_utf8())
	#var data : Variant = json.get_data()
	#var prettified_data : String = JSONBeautifier.beautify_json(json.stringify(data))
	#_log.debug("%s" % prettified_data)
	#
	#if data != null:
		#for player_id in data:
			#if player_id != str(id):
				#connected_players[player_id] = data[player_id]
	#
	#sync_players()
