extends Node3D


func _init():
	Global._root_node = self

func _ready():
	$Player.set_process_input(true)
	$Player.set_process(true)
