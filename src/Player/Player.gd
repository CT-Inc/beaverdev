extends CharacterBody3D
class_name Player

@onready var camera: Camera3D = $FPCamera
#@onready var speed_label: Label = $Control/Speed

var projected_speed: float = 0
var grounded_prev: bool = true
var grounded: bool = true
var wish_dir: Vector3 = Vector3.ZERO

var _latest_mouse_pos := Vector2.ZERO
var _input_vector := Vector3.ZERO
var _velocity := Vector3.ZERO
var _looking_at = null
var _camera_x := 0.0
var _camera_x_new := 0.0
var _camera_y := 0.0

## Camera Motion
func _input(event: InputEvent) -> void:
	# input should focus on capturing inputs and values, processing is done after
	
	# click and esc for using the game
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# rotate camera with mouse
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			_camera_x -= event.relative.x * Global.MOUSE_SENS
			_camera_y = clampf(_camera_y - event.relative.y * Global.MOUSE_SENS, Global.MOUSE_Y_MIN, Global.MOUSE_Y_MAX)

	if event is InputEventMouse:
		_latest_mouse_pos = event.position
	
	### Handle ray cast here, in theory this should be in process?
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * Global.RAY_LENGTH

# Functions for quake-like movement
func clip_velocity(normal: Vector3, overbounce: float, delta) -> void:
	var correction_amount: float = 0
	var correction_dir: Vector3 = Vector3.ZERO
	var move_vector: Vector3 = get_velocity().normalized()
	
	correction_amount = move_vector.dot(normal) * overbounce
	
	correction_dir = normal * correction_amount
	velocity -= correction_dir
	# this is only here cause I have the gravity too high by default
	# with a gravity so high, I use this to account for it and allow surfing
	velocity.y -= correction_dir.y * (Global.GRAVITY/20)

func apply_friction(delta):
	var speed_scalar: float = 0
	var friction_curve: float = 0
	var speed_loss: float = 0
	var current_speed: float = 0
	
	# using projected velocity will lead to no friction being applied in certain scenarios
	# like if wish_dir is perpendicular
	# if wish_dir is obtuse from movement it would create negative friction and fling players
	current_speed = velocity.length()
	
	if(current_speed < 0.1):
		velocity.x = 0
		velocity.y = 0
		return
	
	friction_curve = clampf(current_speed, Global.LIN_FRICTION_SPEED, INF)
	speed_loss = friction_curve * Global.FRICTION * delta
	speed_scalar = clampf(current_speed - speed_loss, 0, INF)
	speed_scalar /= clampf(current_speed, 1, INF)
	
	velocity *= speed_scalar

func apply_acceleration(acceleration: float, top_speed: float, delta):
	var speed_remaining: float = 0
	var accel_final: float = 0
	
	speed_remaining = (top_speed * wish_dir.length()) - projected_speed
	
	if speed_remaining <= 0:
		return
	
	accel_final = acceleration * delta * top_speed
	
	clampf(accel_final, 0, speed_remaining)
	
	velocity.x += accel_final * wish_dir.x
	velocity.z += accel_final * wish_dir.z

func air_move(delta):
	apply_acceleration(Global.ACCEL_AIR, Global.TOP_SPEED_AIR, delta)
	
	clip_velocity(get_wall_normal(), 14, delta)
	clip_velocity(get_floor_normal(), 14, delta)
	
	velocity.y -= Global.GRAVITY * delta

func ground_move(delta):
	floor_snap_length = 0.4
	apply_acceleration(Global.ACCEL, Global.TOP_SPEED_GROUND, delta)
	
	if Input.is_action_pressed("jump"):
		print("jump")
		velocity.y = Global.JUMP_FORCE
	
	if grounded == grounded_prev:
		apply_friction(delta)
	
	if is_on_wall:
		clip_velocity(get_wall_normal(), 1, delta)
		
func _process(delta):
	# angle camera
	# note: var camera is defined @onready
	_camera_x_new = lerpf(_camera_x_new, _camera_x, delta * Global.MOUSE_ACCEL_X)
	self.rotation_degrees.y = _camera_x_new
	camera.rotation_degrees.x = lerpf(camera.rotation_degrees.x, _camera_y, delta * Global.MOUSE_ACCEL_X)
	
	# collider setup, tells us what we are looking at 
	var look_at_ray: RayCast3D = $FPCamera/RayMount/LookAtRayCast
	look_at_ray.force_raycast_update()
	var obj = look_at_ray.get_collider()
	if obj:
		if obj != _looking_at:
			_looking_at = obj
			print("Looking at %s(%s)" % [obj.name, obj.get_class()])
	elif _looking_at:
		_looking_at = null
		
	# get ray where camera is looking
	var target := Vector3.INF
	var from := camera.project_ray_origin(_latest_mouse_pos)
	var to := from + camera.project_ray_normal(_latest_mouse_pos) * Global.RAY_LENGTH
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)
	target = result.position if result else to
	
	var is_shooting := false
	if Input.is_action_just_pressed("shoot"):
		is_shooting = true
	#shooting
	if is_shooting:
		for weapon in $Pivot/Character/Body/Shoulder/ItemMount.get_children():
			print("fire")
			weapon.fire(target)
	
	# process shooting 
	#var is_shooting := false
	#if Input.is_action_just_pressed("shoot"):
	#	is_shooting = true
		
	#if is_shooting: for weapon in $Pivot/Body/Shoulder/ItemMount.get_children():
	#	weapon.fire(target)
	

func _physics_process(delta):
	grounded_prev = grounded
	
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	wish_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	projected_speed = (velocity * Vector3(1,0,1)).dot(wish_dir)
	
	if not is_on_floor():
		grounded = false
		air_move(delta)
	if is_on_floor():
		if velocity.y > 10:
			grounded = false
			air_move(delta)
		else:
			grounded = true
			ground_move(delta)
			
	move_and_slide()
	
	
