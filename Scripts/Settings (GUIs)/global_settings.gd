extends Node

signal bloom_toggled(value)
signal fov_updated(value)
signal mouse_sens_updated(value)
signal brightness_updated(value)
signal game_state_updated(value)

func toggle_fullscreen(value):
	pass
	#OS.window_fullscreen = value

func toggle_vsync(value):
	pass
	
func toggle_bloom(value):
	emit_signal("bloom_toggled", value)

func update_fov(value):
	emit_signal("fov_updated", value)
	Save.game_data.fov = value
	Save.save_data()
	
func update_mouse_sens(value):
	emit_signal("mouse_sens_updated", value)
	Save.game_data.mouse_sens = value
	Save.save_data()
	
func update_brightness(value):
	emit_signal("brightness_updated", value)
	print('should have emitted')
	Save.game_data.brightness = value
	Save.save_data() 
	
func update_game_state(value):
	emit_signal("game_state_updated", value)
	Save.game_data.game_state = value
	Save.save_data()
	print('updating game state ', value)
