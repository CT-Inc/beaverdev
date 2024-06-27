extends Area3D

@onready var player = get_parent()

func _ready():
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)
	
func _on_area_entered(area):
	if area.is_in_group('Water'):
		player._on_player_entered_water()
		
func _on_area_exited(area):
	if area.is_in_group('Water'):
		player.on_player_exited_water()
		
