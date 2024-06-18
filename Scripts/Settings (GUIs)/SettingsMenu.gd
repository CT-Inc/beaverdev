extends Popup

@onready var fov_val = $TabContainer/Gameplay/MarginContainer/GameplaySettings/FOVOption/FOVAmt
@onready var fov_slider = $TabContainer/Gameplay/MarginContainer/GameplaySettings/FOVOption/FOVSlider


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_fov_slider_value_changed(value):
	GlobalSettings.update_fov(value)


func _on_mouse_sens_slider_value_changed(value):
	GlobalSettings.update_mouse_sens(value)
