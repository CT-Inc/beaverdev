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

var current_class: CharacterClass
var health: int
var player_speed

# Signals
signal update_health
signal send_ray

@onready var head = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var weapons_manager = $Head/Camera3D/Weapons_Manager
@onready var fps_rig = $Head/Camera3D/Weapons_Manager/FPS_Rig
@onready var movement = preload("res://Scripts/Player/PlayerMovement.gd").new()

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority():
		return 
	#add_child(movement)
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

func set_class(new_class: CharacterClass):
	current_class = new_class
	self.player_speed = new_class.speed
	self.health = new_class.health
	emit_signal("update_health", self.health, 0)
	if weapons_manager:
		weapons_manager.Initialize(new_class.start_weapons)
	else:
		print("Error: weapons_manager is null")

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
	
	weapons_manager.cur_ray = result
	#if Input.is_action_pressed("shoot"):
		#emitting the weapons_manager, and ray query to weapon_manager.gd
		# weapons_manager.pos and transform.basis are used
		
		# consideration: sending a ray every process frame 
		# better consideration: scrapping this entire thing and just updating weapons_manager.cur_ray
		# every process frame! its easy
		#emit_signal("send_ray", query, result)

func _on_fov_updated(value):
	camera.fov = value

func _on_mouse_sens_updated(value):
	MOUSE_SENS = value
	#print(value)
	
func _update_health(value):
	health += value
	if health <= 0:
		print("Player died")
		queue_free()
	else:
		print("Player health", health)
	emit_signal("update_health", self.health, value)
	

@rpc
func shoot_bullet(origin, direction):
	if is_multiplayer_authority():
		print("shooting herein player.gd")
		var bullet = bullet.instantiate()
		bullet.global_transform.origin = origin
		bullet.look_at(origin + direction)
		get_parent().add_child(bullet)
