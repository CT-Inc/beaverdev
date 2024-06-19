extends CharacterBody3D

# Constants
const SENSITIVITY = 0.004
const HIT_STAGGER = 8.0
const RAY_LENGTH = 500.0
const MOUSE_ACCEL = 10.0
const FOV_CHANGE = 1.5
const BASE_FOV = 75.0
const MOUSE_Y_MAX = 60.0
const MOUSE_Y_MIN = -80.0

# Variables
var bullet = load("res://Scenes/Bullet.tscn")
var instance
var _camera_x := 0.0
var _camera_x_new := 0.0
var _camera_y := 0.0
var _latest_mouse_pos := Vector2.ZERO
var _looking_at = null
var MOUSE_SENS: float = 0.1

# Signals
signal player_hit

@onready var head = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var gun_anim = $Head/Camera3D/Weapons_Manager/Rifle/AnimationPlayer
@onready var gun_barrel = $Head/Camera3D/Weapons_Manager/Rifle/RayCast3D
@onready var weapons_manager = $Head/Camera3D/Weapons_Manager
@onready var movement = preload("res://Scripts/Player/PlayerMovement.gd").new()

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority():
		return 
	add_child(movement)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true
	GlobalSettings.connect("fov_updated", _on_fov_updated)
	GlobalSettings.connect("mouse_sens_updated", _on_mouse_sens_updated)
	print("Child Script is", movement)

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

func _process(delta):
	if not is_multiplayer_authority():
		return
	_camera_x_new = lerpf(_camera_x_new, _camera_x, delta * MOUSE_ACCEL)
	self.rotation_degrees.y = _camera_x_new
	camera.rotation_degrees.x = lerpf(camera.rotation_degrees.x, _camera_y, delta * MOUSE_ACCEL)
	
	var target := Vector3.INF
	var from := camera.project_ray_origin(_latest_mouse_pos)
	var to := from + camera.project_ray_normal(_latest_mouse_pos) * RAY_LENGTH
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)
	target = result.position if result else to
	
	#if Input.is_action_pressed("shoot"):
		#if not gun_anim.is_playing():
			#gun_anim.play("Shoot")
			#instance = bullet.instantiate()
			#instance.position = gun_barrel.global_position
			#instance.transform.basis = gun_barrel.global_transform.basis
			#get_parent().add_child(instance)

func _on_fov_updated(value):
	camera.fov = value

func _on_mouse_sens_updated(value):
	MOUSE_SENS = value
	print(value)

@rpc
func shoot_bullet(origin, direction):
	if is_multiplayer_authority():
		var bullet = bullet.instantiate()
		bullet.global_transform.origin = origin
		bullet.look_at(origin + direction)
		get_parent().add_child(bullet)
