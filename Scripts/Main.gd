extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/Address
@onready var world = $World  # Add a reference to the World node

const Player = preload("res://Scenes/Player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _ready():
	world.visible = false  # Ensure the World is hidden initially
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Ensure mouse is visible


func _unhandled_input(event):
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()

func _on_host_button_pressed():
	_start_game()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	print("Server started. Waiting for clients to connect...")

func _on_join_button_pressed():
	_start_game()
	
	var address = address_entry.text
	enet_peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = enet_peer
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	print("Connecting to server at %s..." % address)

func _start_game():
	main_menu.hide()
	world.visible = true  # Make the World visible


func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	print("Player %s connected" % str(peer_id))

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
		print("Player %s disconnected" % str(peer_id))
