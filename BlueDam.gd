extends Node3D

@export var team: String = "TeamBlue"
var wood_count = 0
@export var wood_needed = 10 #For now we'll use 10 for testing

signal damn_completed(team:String)

func _on_area_3d_body_entered(body):
	print("Player is near the blue damn")
	#We'll eventually have to add a check for the right team adding wood to damn	
	#and body.team === team:
	add_wood(body.wood_amount)

func add_wood(amount):
	wood_count += amount
	update_dam_progress()
	if wood_count >= wood_needed:
		emit_signal("damn_completed", team)
			
func update_dam_progress():
	print("Blue team wood count is", wood_count)
	$ProgressBar.value = float(wood_count) / wood_needed * 100
