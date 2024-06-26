extends Node3D

@onready var timer = $Timer

var max_Branches: int = 5
var cur_Branches: int = 2
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func _on_timer_timeout():
	print("timer echo")
	if cur_Branches < 5:
		cur_Branches += 1
	timer.start()

func _interacted():
	print("interacted")
	if cur_Branches < 1:
		print("No branches on this tree.")
	else:
		cur_Branches -= 1
		print(cur_Branches, " out of ", max_Branches, " branches left.")
		
