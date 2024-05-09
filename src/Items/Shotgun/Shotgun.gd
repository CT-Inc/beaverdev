extends MeshInstance3D
class_name Shotty

#QUICK NOTE: THis is a broken window I guess. But too tired to fix it
# basically the shotgun.tscn file uses rigidbody3d and shotty.tscn uses meshinstance3d
# im not sure which one we're going to use right now, because I think rigidbody has more
# movement flexbility, but theyre both in items/shotgun/ folder for now until i decide

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func fire(target_pos):
	var bullet_type := Global.BulletType._308
	var start_pos = $BulletStartPosition.global_transform.origin
	Global.create_bullet(Global._root_node, start_pos, target_pos, bullet_type)
