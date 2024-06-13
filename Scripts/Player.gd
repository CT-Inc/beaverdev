extends CharacterBody3D

var speed
const WALK_SPEED = 8.0
const SPRINT_SPEED = 10.0 
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.004
const HIT_STAGGER = 8.0

#variables for player bobbing
const BOB_FREQ = 2.4
const BOB_AMP = 0.08 
var t_bob = 0.0

#variables for FOV
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

#signal
signal player_hit

#gravity
var gravity = 9.8

var bullet = load("res://Scenes/Bullet.tscn")
var instance

#mouse constants for now
const MOUSE_ACCEL = 10.0
const RAY_LENGTH = 500.0
const FRICTION: float = 4.0
const ACCEL_AIR: float = 40.0
const ACCEL: float = 12.0
const TOP_SPEED_AIR: float = 2.5
const TOP_SPEED_GROUND: float = 15.0
const GRAVITY: float = 40.0
const JUMP_FORCE: float = 14
const LIN_FRICTION_SPEED: float = 10.0
var MOUSE_SENS: float = 0.1
const MOUSE_Y_MAX: float = 60.0
const MOUSE_Y_MIN: float = -80.0
var projected_speed: float = 0
var grounded_prev: bool = true
var grounded: bool = true
var wish_dir: Vector3 = Vector3.ZERO
var _camera_x := 0.0
var _camera_x_new := 0.0
var _camera_y := 0.0
var _latest_mouse_pos := Vector2.ZERO
var _input_vector := Vector3.ZERO
var _velocity := Vector3.ZERO
var _looking_at = null

@onready var head = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var gun_anim = $Head/Camera3D/Weapons_Manager/Rifle/AnimationPlayer
@onready var gun_barrel = $Head/Camera3D/Weapons_Manager/Rifle/RayCast3D
@onready var weapons_manager = $Head/Camera3D/Weapons_Manager


func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority():
		return 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true
	GlobalSettings.connect("fov_updated", _on_fov_updated)
	GlobalSettings.connect("mouse_sens_updated", _on_mouse_sens_updated)

	
func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return 
	
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			_camera_x -= event.relative.x * MOUSE_SENS
			_camera_y = clampf(_camera_y - event.relative.y * MOUSE_SENS, MOUSE_Y_MIN, MOUSE_Y_MAX)
		if event is InputEventMouse:
			_latest_mouse_pos = event.position
		if Input.is_action_pressed("switch_weapon_up"):
			weapons_manager.switch_weapon(1)  # Scroll up
		if Input.is_action_pressed("switch_weapon_down"):
			weapons_manager.switch_weapon(-1) # Scroll down

	
func _unhandled_input(event):
	if not is_multiplayer_authority():
		return  # Only the local player handles input
	
	if event is InputEventMouseMotion:
		pass
		#head.rotate_y(-event.relative.x * SENSITIVITY)
		#camera.rotate_x(-event.relative.y * SENSITIVITY)
		#camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		
func _process(delta):
	if not is_multiplayer_authority():
		return
		# angle camera
	_camera_x_new = lerpf(_camera_x_new, _camera_x, delta * MOUSE_ACCEL)
	self.rotation_degrees.y = _camera_x_new
	camera.rotation_degrees.x = lerpf(camera.rotation_degrees.x, _camera_y, delta * MOUSE_ACCEL)
	
	# get ray where camera is looking
	var target := Vector3.INF
	var from := camera.project_ray_origin(_latest_mouse_pos)
	var to := from + camera.project_ray_normal(_latest_mouse_pos) * RAY_LENGTH
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)
	target = result.position if result else to
	
	#Shooting
	if Input.is_action_pressed("shoot"):
		if !gun_anim.is_playing():
			gun_anim.play("Shoot")
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)
				


func _physics_process(delta):
	#Handle Script
	#Leaving this in case we want to add sprint later
	#if Input.is_action_just_pressed("sprint"):
	#	speed = SPRINT_SPEED
	#else:
	#	speed = WALK_SPEED
	if not is_multiplayer_authority():
		return
	grounded_prev = grounded
	
	#Get the input direction and handle the movement/deceleration
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	wish_dir = (transform.basis * Vector3(input_dir.x, 0 , input_dir.y)).normalized()
	projected_speed = (velocity * Vector3(1,0,1)).dot(wish_dir)
	 
	if not is_on_floor():
			set_move(false, delta, "air_move")
	if is_on_floor():
		if velocity.y > 10:
			set_move(false, delta, "air_move")
		else:
			set_move(true, delta, "ground_move")

		#Head bob 
		#Leaving this to tinker with later, player moves too fast right now
		#set_bob(delta, velocity)
		
		#FOV
		#set_fov(delta, velocity)
				
	move_and_slide()
			
			
func set_fov(delta, velocity):
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
			
func set_move(grounded_status, delta, air_or_ground):
	grounded = grounded_status
	call(air_or_ground, delta)
	
func set_bob(delta, velocity):
	pass
	#t_bob += delta * velocity.length() * float(is_on_floor()) / 100.0
	#camera.transform.origin = _headbob(t_bob)

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func hit(dir):
	emit_signal("player_hit")
	velocity += dir * HIT_STAGGER

func air_move(delta):
	apply_acceleration(ACCEL_AIR, TOP_SPEED_AIR, delta)
	
	clip_velocity(get_wall_normal(), 14, delta)
	clip_velocity(get_floor_normal(), 14, delta)
	
	velocity.y -= GRAVITY * delta

func ground_move(delta):
	floor_snap_length = 0.4
	apply_acceleration(ACCEL, TOP_SPEED_GROUND, delta)
	
	if Input.is_action_pressed("jump"):
		print("jump")
		velocity.y = JUMP_FORCE
	
	if grounded == grounded_prev:
		apply_friction(delta)
	
	if is_on_wall:
		clip_velocity(get_wall_normal(), 1, delta)
		
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
	velocity.y -= correction_dir.y * (GRAVITY/20)

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
	
	friction_curve = clampf(current_speed, LIN_FRICTION_SPEED, INF)
	speed_loss = friction_curve * FRICTION * delta
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
	
@rpc
func shoot_bullet(origin, direction):
	if is_multiplayer_authority():
		var bullet = bullet.instantiate()
		bullet.global_transform.origin = origin
		bullet.look_at(origin + direction)
		get_parent().add_child(bullet)

func _on_fov_updated(value):
	camera.fov = value

func _on_mouse_sens_updated(value):
	MOUSE_SENS = value
	print(value)
