extends CharacterBody3D

# Constants
const WALK_SPEED = 8.0
const SPRINT_SPEED = 10.0
const JUMP_VELOCITY = 4.5
const FRICTION: float = 4.0
const ACCEL_AIR: float = 40.0
const ACCEL: float = 12.0
const TOP_SPEED_AIR: float = 2.5
const TOP_SPEED_GROUND: float = 15.0
const GRAVITY: float = 40.0
const JUMP_FORCE: float = 14
const LIN_FRICTION_SPEED: float = 10.0

# Variables
var gravity = 9.8
var projected_speed: float = 0
var grounded_prev: bool = true
var grounded: bool = true
var wish_dir: Vector3 = Vector3.ZERO
var _input_vector := Vector3.ZERO
var _velocity := Vector3.ZERO

const HIT_STAGGER = 8.0


@onready var player : CharacterBody3D = get_parent() as CharacterBody3D

func _physics_process(delta):
	if not player.is_multiplayer_authority():
		return
	grounded_prev = grounded
	
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	wish_dir = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	projected_speed = (player.velocity * Vector3(1, 0, 1)).dot(wish_dir)
	 
	if not player.is_on_floor():
		set_move(false, delta, "air_move")
	if player.is_on_floor():
		if player.velocity.y > 10:
			set_move(false, delta, "air_move")
		else:
			set_move(true, delta, "ground_move")
				
	player.move_and_slide()

func set_move(grounded_status, delta, air_or_ground):
	grounded = grounded_status
	call(air_or_ground, delta)

func hit(dir):
	player.emit_signal("player_hit")
	player.velocity += dir * HIT_STAGGER

func air_move(delta):
	apply_acceleration(ACCEL_AIR, TOP_SPEED_AIR, delta)
	clip_velocity(get_wall_normal(), 14, delta)
	clip_velocity(get_floor_normal(), 14, delta)
	player.velocity.y -= GRAVITY * delta

func ground_move(delta):
	floor_snap_length = 0.4
	apply_acceleration(ACCEL, TOP_SPEED_GROUND, delta)
	
	if Input.is_action_pressed("jump"):
		print("jump")
		player.velocity.y = JUMP_FORCE
	
	if grounded == grounded_prev:
		apply_friction(delta)
	
	if is_on_wall:
		clip_velocity(get_wall_normal(), 1, delta)

func clip_velocity(normal: Vector3, overbounce: float, delta) -> void:
	var correction_amount: float = 0
	var correction_dir: Vector3 = Vector3.ZERO
	var move_vector: Vector3 = player.velocity.normalized()
	
	correction_amount = move_vector.dot(normal) * overbounce
	
	correction_dir = normal * correction_amount
	player.velocity -= correction_dir
	player.velocity.y -= correction_dir.y * (GRAVITY / 20)

func apply_friction(delta):
	var speed_scalar: float = 0
	var friction_curve: float = 0
	var speed_loss: float = 0
	var current_speed: float = 0
	
	current_speed = player.velocity.length()
	
	if current_speed < 0.1:
		player.velocity.x = 0
		player.velocity.y = 0
		return
	
	friction_curve = clampf(current_speed, LIN_FRICTION_SPEED, INF)
	speed_loss = friction_curve * FRICTION * delta
	speed_scalar = clampf(current_speed - speed_loss, 0, INF)
	speed_scalar /= clampf(current_speed, 1, INF)
	
	player.velocity *= speed_scalar

func apply_acceleration(acceleration: float, top_speed: float, delta):
	var speed_remaining: float = 0
	var accel_final: float = 0
	
	speed_remaining = (top_speed * wish_dir.length()) - projected_speed
	
	if speed_remaining <= 0:
		return
	
	accel_final = acceleration * delta * top_speed
	
	clampf(accel_final, 0, speed_remaining)
	
	player.velocity.x += accel_final * wish_dir.x
	player.velocity.z += accel_final * wish_dir.z
