extends WorldEnvironment


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSettings.connect("bloom_toggled", _on_bloom_toggled)
	#GlobalSettings.connect("brightness_updated", _on_brightness_updated)
	
func _on_bloom_toggled(value):
	environment.glow_enabled = value
	
func _on_brightness_updated(value):
	environment.adjustment_brightness = value


