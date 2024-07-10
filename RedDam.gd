extends Node3D

@export var team: String = "TeamRed"
var wood_count = 0
@export var wood_needed = 10 #For now we'll use 10 for testing

signal damn_completed(team:String)
signal player_near_dam(dam: Node3D, is_near: bool)

var player_in_range = null

func _ready():
	$Area3D.add_to_group("Dam")

func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		print("Player is near the red dam")
		emit_signal("player_near_dam", self, true)
		

func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		print("Player has left the red dam")
		emit_signal("player_near_dam", self,  false)

func add_wood(amount):
	wood_count += amount
	update_dam_progress()
	if wood_count >= wood_needed:
		emit_signal("damn_completed", team)

func update_dam_progress():
	print("Red team wood count is", wood_count)
	$CanvasLayer/HBoxContainer/ProgressBar.value = float(wood_count) / wood_needed * 100
