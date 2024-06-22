extends StaticBody3D

var health: int = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health <= 0:
		print("You killed the dummy")
		queue_free()


func update_health(value):
	health = health + value
	print("Dummy HP is now: ", health)
