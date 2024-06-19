extends WorldEnvironment



# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSettings.connect("bloom_toggled", _on_bloom_toggled)
	GlobalSettings.connect("brightness_updated", _on_brightness_updated)
	# This needs to be set to true to adjust environment settings.
	environment.adjustment_enabled = true
	
func _on_bloom_toggled(value):
	environment.glow_enabled = value
	
func _on_brightness_updated(value):
	environment.adjustment_brightness = value / 50.0


