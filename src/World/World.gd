extends Node3D


func _init():
	Global._root_node = self

func _ready():
	## Option: When we load the game, do we want to immediately capture the mouse?
	## Or do we want to have the user click on the screen first
	## if we do, Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) and change Player.gd _input()
	$Player.set_process_input(true)
	$Player.set_process(true)
	
