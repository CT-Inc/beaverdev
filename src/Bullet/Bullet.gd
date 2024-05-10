extends Node3D
class_name Bullet

var _bullet_type := -1
var _mass := -1.0
var _max_distance := -1.0
var _glow = null
var _speed := 0.0
var _velocity : Vector3
var _gravity_velocity := 0.0
var _is_setup := false

var _total_distance := 0.0
@onready var _ray : RayCast3D = $RayCast3D

const MIN_BOUNCE_DISTANCE := 0.1
const MIN_RAYCAST_DISTANCE := 0.05

func _physics_process(delta):
	if not _is_setup: return
	var is_destroyed := false
	
	_glow.update(self.global_transform.origin)
	
	var distance: float = _velocity.length() * delta
	self.transform.origin -= _velocity * delta
	
	_gravity_velocity = clampf(_gravity_velocity + 9.8 * delta, 0, 9.8)
	self.transform.origin.y -= _gravity_velocity
	
	if distance > MIN_RAYCAST_DISTANCE:
		_ray.target_position.z = -distance
		_ray.transform.origin.z = distance
	else:
		_ray.target_position.z = -MIN_RAYCAST_DISTANCE
		_ray.transform.origin.z = MIN_RAYCAST_DISTANCE
		
	#check for hit
	_ray.force_raycast_update()
	if _ray.is_colliding():
		var collider:= _ray.get_collider()
		print("Bullet hit %s" % [collider.name])
		
		# move bullet back to pos of collision
		self.global_transform.origin = _ray.get_collision_point()
		
		# ricochet functionality, here need to be added
		
		#hit object, to be added
		if collider.is_in_group("terrain"):
			print("hitting terrain")
			is_destroyed = true
		else:
			is_destroyed = true
			
		Global.create_bullet_spark(self.global_transform.origin)
			
	#update glow
	_glow.update(self.global_transform.origin)
			
	#delete slow bullet
	if distance < 1.0:
		is_destroyed = true
		
	#delete if bullet travels max distance
	_total_distance += distance
	if _total_distance > _max_distance:
		is_destroyed = true
		
	if is_destroyed:
		self.queue_free()
		_glow._is_parent_bullet_destroyed = true
			
		
func start(bullet_type):
	_bullet_type = bullet_type
	var entry : Dictionary = Global.DB["Bullets"][_bullet_type]
	_mass = entry["mass"]
	_max_distance = entry["max_distance"]
	_speed = entry["speed"]
	_velocity = self.transform.basis.z * _speed
	
	# add bullet glow
	_glow = Global._scene_bullet_glow.instantiate()
	Global._root_node.add_child(_glow)
	_glow.global_transform.origin = self.global_transform.origin
	_glow.start(self.global_transform.origin)
	
	_is_setup = true
