extends KinematicBody2D

var in_game = true
export var x_const = 40.0
export var forced_fall_const = 150.0
export var jump_const = 300.0
export var GRAVITY = 10.0
export var websocket_url = "wss://websocket-blue-jelly-3.jonathanbreitg.repl.co"
var jumped_once = false
var jumped_twice = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var move_vect = Vector2.ZERO
onready var scene_name = get_tree().get_current_scene().get_name()
# Called when the node enters the scene tree for the first time.
onready var ids = []
var id = Globals.id
var color = Globals.color

var _client = WebSocketClient.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.material.set_shader_param("r",color.r)
	$Sprite.material.set_shader_param("g",color.g)
	$Sprite.material.set_shader_param("b",color.b)
	print(scene_name)
	if scene_name == "waiting-area":
		in_game = false
		print("not in game")
	else:
		in_game = true
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")

	# Initiate connection to the given URL.
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input_axis = Vector2.ZERO
	
	if Input.is_action_pressed("ui_left"):
		input_axis.x = -x_const
	elif Input.is_action_pressed("ui_right"):
		input_axis.x = x_const
	if Input.is_action_just_pressed("ui_down"):
		input_axis.y = forced_fall_const
	elif Input.is_action_just_pressed("ui_up"):
		if (jumped_once && !jumped_twice):
			jumped_twice = true
			move_vect.y -= jump_const
			
		elif (!jumped_once):
			jumped_once = true
			move_vect.y -= jump_const
		else:
			print("already jumped too much")
	
	move_vect.x = input_axis.x
	print(move_vect,input_axis)
	move_vect.y = move_vect.y + input_axis.y
	
	if is_on_floor():
		if !jumped_once:
			move_vect.y = 0
		jumped_once = false
		jumped_twice = false
	else:
		move_vect.y += GRAVITY 
	move_and_slide(move_vect,Vector2.UP)
	_client.poll()
	if in_game:
		var to_send = ""
		to_send += "d:"
		to_send += "["
		to_send += var2str(global_transform.origin)
		to_send += "~"
		to_send += id
		to_send += "]"
		#print(to_send)
		_client.get_peer(1).put_packet(to_send.to_utf8())
	
	
	
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		print("SHOOT AT ",event.position)
		
		




func _closed(was_clean=false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	get_tree().change_scene("res://scenes/main-menu.tscn")
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.

	_client.get_peer(1).put_packet(("wi".to_utf8()))
	_client.get_peer(1).put_packet("j:".to_utf8())
	_client.get_peer(1).put_packet(("ss:"+var2str(color.r) + ',' + var2str(color.g)+ ','+var2str(color.b)).to_utf8())

func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	var data = _client.get_peer(1).get_packet().get_string_from_utf8()
	data = data.replace('"',"")
	#print("Got data from server: ", data)
	print(data)
	if (data.begins_with("id:")):
		print("got other id")
		if (data.substr(3) != id && ids.has(data.substr(3)) == false):
			ids.append(data.substr(3))
			print(ids)
			get_parent().get_parent().ids = ids
	
	if (data.begins_with("uid")):
		data = data.substr(3)
		id = data
		Globals.id = id
		print("our id is:",id)
	
	if !in_game:
		if (data.begins_with("STARTING GAME")):
			get_parent().get_parent().get_node("Label").text = "STARTING GAME..."
			print("starting epic game")
			if int(id) == -1:
				id =data.trim_prefix("STARTING GAME")
				
				print("our id is:",id)
				Globals.id = id
			
			#get_tree().change_scene("res://scenes/map.tscn")
			get_parent().get_parent().start_game()
			in_game = true
			_client.get_peer(1).put_packet("colors:".to_utf8())
			return
		elif (data.begins_with("game is already running...")):
			get_parent().get_parent().get_node("Label").text = "game is already running..."
			if int(id) == -1:
				id =data.trim_prefix("game is already running...")
				Globals.id = id
			print("game ongoing")
		elif (data.begins_with("waiting for other players to join...")):
			get_parent().get_parent().get_node("Label").text = "waiting for other players to join..."
			if int(id) == -1:
				id =data.trim_prefix("waiting for other players to join...")
				Globals.id = id
			print("waiting")
		elif (int(data) < 16):
			Globals.player_num = int(data)
			print("this many other players: ",data)
		else:
			get_parent().get_parent().get_node("Label").text = data
	if in_game:
		#other players move logic...
		#print('no logic yet')
		get_parent().get_parent()._process_data(data)
		

   # Print the size of the viewport.
  # print("Viewport Resolution is: ", get_viewport_rect().size)

func get_name_of_mat(mat: Material):
	return mat.resource_path.get_file().trim_suffix('.material')
