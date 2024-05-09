extends MeshInstance3D
class_name BulletSpark


func _on_timer_die_timeout():
	self.queue_free()
