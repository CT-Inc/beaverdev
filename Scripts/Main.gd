extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/Address
@onready var world = $World  # Add a reference to the World node
@onready var settings_menu = $SettingsMenu
@onready var world_env = $WorldEnvironment


const Player = preload("res://Scenes/Player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

var settings_open = false

func _ready():
	world.visible = false  # Ensure the World is hidden initially
	settings_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Ensure mouse is visible
	
	if OS.has_feature("dedicated_server"):
		print("Running in headless mode, starting server automatically")
		_start_server()
	else: 
		main_menu.show()

func _unhandled_input(event):
	#when pressing quit to close the menu, the signal _popup_hide() is called,
	#not this area
	if Input.is_action_just_pressed("Quit"):
		# make sure we are not in main menu 
		if main_menu.is_visible_in_tree():
			return
		settings_menu.popup_centered()
		_handle_gui_shit(true)
		

func _on_host_button_pressed():
	_start_server()
	

func _on_join_button_pressed():
	_start_game()
	
	var address = address_entry.text 
	var result = enet_peer.create_client(address, PORT)
	if result != OK:
		print("Failed to connect to server: %d" % result)
		return 
	multiplayer.multiplayer_peer = enet_peer
	
	print("Connecting to server at %s..." % address)
	
func _start_server():
	_start_game()
	
	var result = enet_peer.create_server(PORT)
	if result != OK:
		print("Failed to create s!erver: %d" % result)
		return
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)

	if not OS.has_feature("dedicated_server"):
		add_player(multiplayer.get_unique_id())
	
	print("Server started. Waiting for clients to connect...")

func _start_game():
	main_menu.hide()
	world.visible = true  # Make the World visible
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player, true)
	print("Player %s connected" % str(peer_id))

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
		print("Player %s disconnected" % str(peer_id))
		



func _on_quit_game_pressed():
	get_tree().quit()


func _on_settings_pressed():
	settings_menu.popup_centered()
	
func _handle_gui_shit(state):
	settings_open = state
	if settings_open:
		print("we are visible/OPEN MENU MODE/taking control from you")
		GlobalSettings.update_game_state(0)
		# restrict player input to gui only, apply blur or some thing 
	else:
		# give back player input
		print("we are closing now fuck you bye bbye/giving back movement control")
		GlobalSettings.update_game_state(1)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#remove control of player input froom game world and oonly popup

	
func _on_settings_menu_popup_hide():
	_handle_gui_shit(false)
	#
