#Main.gd
#This script is responsible for the main game logic, including the main menu, server creation, player connection, and game start.

extends Node

#References to UI elements
@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/Address
@onready var settings_menu = $SettingsMenu

#Reference to the World node
@onready var world = $World  

@onready var world_env = $WorldEnvironment
var settings_open = false

#Preload player and the class selection menu scenes
const Player = preload("res://Scenes/Player.tscn")
const ClassSelectionMenu = preload("res://Scenes/ClassSelectionMenu.tscn")

#Define server port and initialize the EnetMultiplayerPeer for networking
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

#varialbe declarations
var class_selection_menu
var player
var Weapon_Stack = [] # Add this line to declare Weapon_Stack

enum GameState{
	MAIN_MENU,
	CLASS_SELECTION,
	IN_GAME
}

var current_state = GameState.MAIN_MENU
@onready var main = $"."

func _ready():
	print("I am main node", main)
	#Hide the World and Settings menu by default
	world.visible = false  
	settings_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	
	#If the game is running on a dedicated server, the server will start autmatically
	if OS.has_feature("dedicated_server"):
		print("Running in headless mode, starting server automatically")
		_start_server()
	else: 
		#Otherwise, show the main menu
		main_menu.show()
		
	current_state = GameState.MAIN_MENU

func _unhandled_input(event):
	if Input.is_action_just_pressed("Quit"):
		if main_menu.is_visible_in_tree():
			return
		settings_menu.popup_centered()
		_handle_gui_shit(true)
		
		
func _on_host_button_pressed():
	#Start server when the host button is pressed
	_start_server()
	
	
#When the join button is pressed, connect to the server using the address entered in the text field
func _on_join_button_pressed():
	_show_class_selection_menu()
	var address = address_entry.text 
	var result = enet_peer.create_client(address, PORT)
	if result != OK:
		print("Failed to connect to server: %d" % result)
		return 
	multiplayer.multiplayer_peer = enet_peer
	
	print("Connecting to server at %s..." % address)
	current_state = GameState.CLASS_SELECTION
	
#Start the server and show the class selection menu
func _start_server():
	_show_class_selection_menu()
	var result = enet_peer.create_server(PORT)
	if result != OK:
		print("Failed to create s!erver: %d" % result)
		return
	# Set the multiplayer peer and connect the peer_connected and peer_disconnected signals
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	if not OS.has_feature("dedicated_server"):
		print("no dedicated server")
	
	print("Server started. Waiting for clients to connect...")
	
#Show the class selection menu
func _show_class_selection_menu():
	main_menu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	class_selection_menu = ClassSelectionMenu.instantiate()
	add_child(class_selection_menu)
	class_selection_menu.connect("class_selected" , _on_class_selected)
	current_state = GameState.CLASS_SELECTION
	
#When a class is selected, start the game with the selected class
func _on_class_selected(className):
	print("Class selected: %s" % className)
	class_selection_menu.queue_free()
	_start_game(className)
	
func _start_game(className):
	current_state = GameState.IN_GAME
	world.visible = true  # Make the World visible
	add_player(multiplayer.get_unique_id(), className)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("Game started with class: %s" % className)

func add_player(peer_id, className = ""):
	print("Adding player with ID: %s" % str(peer_id))
	var new_player = Player.instantiate()
	new_player.name = str(peer_id)
	add_child(new_player, true)
	print("Player %s connected" % str(peer_id))
	
	if className != "":
		var class_resource_path = "res://Scripts/Classes/%s.tres" % className
		print("Loading class resource from: %s" % class_resource_path)
		var class_resource = load(class_resource_path)
		if class_resource != null:
			print("Class resource loaded successfully")
			new_player.set_class(class_resource)
		else:
			print("Failed to load class resource")
	#rpc_id(peer_id, "_init_player_weapons", Weapon_Stack)
	

@rpc
func _init_player_weapons(start_weapons):
	if player != null:
		player.weapon_manager.Initialize(start_weapons)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
		print("Player %s disconnected" % str(peer_id))
		
func _on_peer_connected(peer_id):
	print("Peer connected: %d" % peer_id)
	if OS.has_feature("dedicated_server"):
		add_player(peer_id)
		
func _on_peer_disconnected(peer_id):
	print("Peer disconnected: %d" % peer_id)
	remove_player(peer_id)

func _on_quit_game_pressed():
	get_tree().quit()


func _on_settings_pressed():
	print("settings")
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
