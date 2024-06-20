extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/Address
@onready var world = $World  # Add a reference to the World node
@onready var settings_menu = $SettingsMenu


const Player = preload("res://Scenes/Player.tscn")
const ClassSelectionMenu = preload("res://Scripts/Settings (GUIs)/ClassSelectionMenu.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()
var class_selection_menu
var player

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
	if Input.is_action_just_pressed("Quit"):
		settings_menu.popup_centered()
		
		

func _on_host_button_pressed():
	_start_server()
	

func _on_join_button_pressed():
	_show_class_selection_menu()
	
	var address = address_entry.text 
	var result = enet_peer.create_client(address, PORT)
	if result != OK:
		print("Failed to connect to server: %d" % result)
		return 
	multiplayer.multiplayer_peer = enet_peer
	
	print("Connecting to server at %s..." % address)
	
func _start_server():
	_show_class_selection_menu()
	
	var result = enet_peer.create_server(PORT)
	if result != OK:
		print("Failed to create s!erver: %d" % result)
		return
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)

	if not OS.has_feature("dedicated_server"):
		add_player(multiplayer.get_unique_id(),"")
	
	print("Server started. Waiting for clients to connect...")
	
func _show_class_selection_menu():
	main_menu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	class_selection_menu = ClassSelectionMenu.instantiate()
	add_child(class_selection_menu)
	class_selection_menu.connect("class_selected" , _on_class_selected)
	
func _on_class_selected(className):
	print("Class selected: %s" % className)
	_start_game(className)
	class_selection_menu.queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _start_game(className):
	world.visible = true  # Make the World visible
	add_player(multiplayer.get_unique_id(), className)
	print("Game started with class: %s" % className)

func add_player(peer_id, className = ""):
	if player == null:
		player = Player.instantiate()
		player.name = str(peer_id)
		if className != "":
			player.set_class(load("res://classes/%s.tres" % className))
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
	print("settings")
	settings_menu.popup_centered()
	
	

