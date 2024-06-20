extends Popup

@onready var fov_val = $TabContainer/Gameplay/MarginContainer/GameplaySettings/FOVOption/FOVAmt
@onready var fov_slider = $TabContainer/Gameplay/MarginContainer/GameplaySettings/FOVOption/FOVSlider
@onready var mouse_sens_val = $TabContainer/Gameplay/MarginContainer/GameplaySettings/MouseSensOption/MouseSensAmt
@onready var mouse_sens_slider = $TabContainer/Gameplay/MarginContainer/GameplaySettings/MouseSensOption/MouseSensSlider
@onready var brightness_slider = $TabContainer/Video/MarginContainer/VideoSettings/BrightnessSlider
# Called when the node enters the scene tree for the first time.
func _ready():
	fov_slider.value = Save.game_data.fov
	mouse_sens_slider.value = Save.game_data.mouse_sens
	brightness_slider.value = Save.game_data.brightness 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_fov_slider_value_changed(value):
	GlobalSettings.update_fov(value)
	fov_val.text = str(value)

func _on_mouse_sens_slider_value_changed(value):
	GlobalSettings.update_mouse_sens(value)
	mouse_sens_val.text = str(value)
	
func _on_brightness_slider_value_changed(value):
	GlobalSettings.update_brightness(value)
