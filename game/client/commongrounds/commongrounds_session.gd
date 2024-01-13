extends Node
class_name CommongroundsSession

signal authorizing
signal healthy

const host = "commongrounds-57371-default-rtdb.firebaseio.com/"
const base_url = "https://%s" % host

@export var commongrounds : Commongrounds
@export var http: HTTPRequest

var players = {}
var player_nodes = {}

var local_player = {}
var local_player_buffer = []

@onready var _log : LogStream = LogStream.new("Commongrounds", Log.current_log_level)

func _ready():
	await Global.go_ahead
	get_tree().set_auto_accept_quit(false)
	
	await connect_player()
	start_player_stream()
	start_write_player()

func _process(_delta):
	var new_local_player = {
		"id": Global.local_player_id,
		"px": commongrounds.local_player_node.position.x,
		"py": commongrounds.local_player_node.position.y,
	}
	if new_local_player.hash() != local_player.hash():
		local_player = new_local_player
		local_player_buffer.append(new_local_player)

func _notification(what):
	if (what == NOTIFICATION_WM_CLOSE_REQUEST):
		await disconnect_player()
		get_tree().quit()

func start_write_player():
	while true:
		if local_player_buffer.size() > 0:
			var curr_player_data = local_player_buffer[local_player_buffer.size() -1]
			local_player_buffer.clear()
			await write_player(Global.local_player_id, curr_player_data)
		await get_tree().process_frame

func connect_player():
	_log.info("Initializing player '%s' ..." % Global.local_player_id)
	var player = {
		"id": Global.local_player_id,
	}
	await write_player(Global.local_player_id, player)
	_log.info("Player initialized!")

func disconnect_player():
	_log.info("Disconnecting player '%s' ..." % Global.local_player_id)
	await delete_player(Global.local_player_id)
	_log.info("Player disconnected!")
	
func start_player_stream():
	healthy.emit()
	_log.info("Connecting to host...")
	var tcp = StreamPeerTCP.new()
	var err = tcp.connect_to_host(host, 443)
	_log.warn("Error connecting to host: " + error_string(err)) # Make sure connection is OK.
	healthy.emit()
	
	while tcp.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		tcp.poll()
		await get_tree().process_frame
	_log.info("Conected: ", tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED)

	_log.info("Connecting to stream...")
	healthy.emit()
	var stream = StreamPeerTLS.new()
	err = stream.connect_to_stream(tcp, host, TLSOptions.client())
	_log.warn("Error connecting to stream: " + error_string(err)) # Make sure connection is OK.
	
	while true:
		stream.poll()
		await get_tree().create_timer(1.0).timeout
		var status = stream.get_status()
		_log.info("stream status: ", status)
		if status == StreamPeerTLS.STATUS_CONNECTED:
			break
		await get_tree().create_timer(0.1).timeout
	
	var request = "GET https://%s/players.json HTTP/1.1\n" % host
	request += "Host: %s\n" % host
	request += "Accept: text/event-stream\n\n"
	stream.put_data(request.to_utf8_buffer())
	healthy.emit()
	
	var initialRequest = false
	while true:
		# Poll the stream to ensure connection is valid and check for availalbe bytes.
		stream.poll()
		var available_bytes: int = stream.get_available_bytes()
		if available_bytes > 0:
			var data: Array = stream.get_partial_data(available_bytes)
			# Check for read error.
			if data[0] != OK:
				_log.err("Error getting data from stream: ", data[0])
			else:
				var response : String = data[1].get_string_from_utf8()
				if !initialRequest:
					if "HTTP/1.1 200 OK" not in response:
						_log.err("Non-ok status code received from stream request: " + response)
					else:
						_log.info("Stream started listening!")
						await load_all_players()
				else :
					process_event(response)
				
				initialRequest = true
		await get_tree().process_frame
	
	stream.disconnect_from_stream()
	tcp.disconnect_from_host()

func process_event(event_data: String):
	var lines = event_data.replace(" ", "").split("\n")
	var event = lines[0].split("event:")[1]
	var data = lines[1].split("data:")[1]
	var json = JSON.new()
	json.parse(data)
	var jsonData = json.get_data()
	
	if event != "put":
		_log.info("unhandled event '%s' with data '%s'" % [event, data])
	else:
		var path = jsonData["path"]
		var id = path.split("/")[1]
		
		if id == "":
			return
		
		# ignore local player
		if id == Global.local_player_id:
			return
		
		if id not in players:
			_log.info("New player with id '%s' joined" % id)
		
		if id in players and jsonData["data"] == null:
			_log.info("Player with id '%s' left" % id)
			players.erase(id)
		else:
			players[id] = jsonData["data"]
		sync_players()

func sync_players():
	for id in players:
		if id not in player_nodes:
			var node: User = commongrounds.spawn_user()
			player_nodes[id] = node
		
		var pd = players[id]
		
		if pd is Dictionary:
			if "px" in pd and "py" in pd:
				player_nodes[id].set_target_position(Vector2(pd["px"], pd["py"]))
			
		player_nodes[id].set_player_name(id)
		
	for id in player_nodes:
		if id not in players:
			player_nodes[id].queue_free()
			player_nodes.erase(id)
			break

func delete_player(player_id: String):
	local_player_buffer.clear()
	http.cancel_request()
	http.request("%s/players/%s.json" % [base_url, player_id],
		[], HTTPClient.METHOD_DELETE)
	var _response = await http.request_completed

func write_player(player_id: String, data: Dictionary):
	http.request("%s/players/%s.json" % [base_url, player_id],
		[], HTTPClient.METHOD_PUT, JSON.stringify(data))
	var _response = await http.request_completed

func load_all_players():
	var req = "%s/players.json" % base_url
	http.request(req)
	var response = await http.request_completed
	var json = JSON.new()
	json.parse(response[3].get_string_from_utf8())
	var data = json.get_data()
	_log.info("%s" % data)
	
	if data != null:
		for player_id in data:
			if player_id != Global.local_player_id:
				players[player_id] = data[player_id]
				
	_log.info("loaded players: ", players)
	sync_players()
