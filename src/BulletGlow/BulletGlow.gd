extends MeshInstance3D
class_name BulletGlow

var _points : Array[Vector3] = []
var _prev_pos := Vector3.ZERO
var _is_parent_bullet_destroyed := false

@onready var _immediate_mesh : ImmediateMesh = self.mesh

func update(parent_pos):
	#Add another point if it moved far enough
	var distance := _prev_pos.distance_to(parent_pos)
	if distance > 0.1:
		_prev_pos = parent_pos
		
		_points.append(parent_pos - self.global_transform.origin)
		
		if _points.size() > 6:
			_points.pop_front()
			
func _physics_process(_delta):
	if _is_parent_bullet_destroyed:
		if not _points.is_empty():
			_points.pop_front()
		else:
			self.queue_free()
			
func _process(_delta):
	if not _immediate_mesh: return
	if _points.size() < 2: return
	
	#draw line
	_immediate_mesh.clear_surfaces()
	_immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	for i in _points.size():
		if i + 1 < _points.size():
			var a := _points[i]
			var b := _points[i+1]
			_immediate_mesh.surface_add_vertex(a)
			_immediate_mesh.surface_add_vertex(b)
	_immediate_mesh.surface_end()
	
func start(parent_pos):
	_points.append(parent_pos - self.global_transform.origin)
