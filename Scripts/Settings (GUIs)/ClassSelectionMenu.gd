extends Control

signal class_selected

func _ready():
	$VBoxContainer/DefaultBeaver_Button.connect("pressed", _on_defaultBeaver_button_pressed)
	
func _on_defaultBeaver_button_pressed():
	emit_signal("class_selected", "Default_Beaver")
