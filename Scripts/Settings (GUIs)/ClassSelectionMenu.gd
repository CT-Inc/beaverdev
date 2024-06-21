extends Control

signal class_selected

func _ready():
	$PanelContainer/VBoxContainer/DefaultBeaver_Button.connect("pressed", _on_defaultBeaver_button_pressed)
	$PanelContainer/VBoxContainer/BeaverShotgun_Button.connect("pressed", _on_shotgunBeaver_button_pressed)
	
func _on_defaultBeaver_button_pressed():
	emit_signal("class_selected", "Default_Beaver")

func _on_shotgunBeaver_button_pressed():
	emit_signal("class_selected", "Shotgun_Beaver")
