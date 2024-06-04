extends Node

signal bloom_toggled(value)
signal fov_updated(value)
signal mouse_sens_updated(value)

func toggle_fullscreen(value):
	pass
	#OS.window_fullscreen = value

func toggle_vsync(value):
	pass
	
func toggle_bloom(value):
	emit_signal("bloom_toggled", value)

func update_fov(value):
	emit_signal("fov_updated", value)
	
func update_mouse_sens(value):
	emit_signal("mouse_sens_updated", value)
