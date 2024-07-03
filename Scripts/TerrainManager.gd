extends Node

var terrain3d

func set_terrain(terrain):
	terrain3d = terrain
	
func set_camera(camera):
	if terrain3d:
		terrain3d.set_camera(camera)
