extends CharacterBody3D

@export var speed: float = 5.0
@export var rotation_speed:  float = 2.0
@export var bullet_scene = preload("res://Scenes/Bullet.tscn")
@export var shoot_interval = 2.0

const SENSITIVITY = 0.004
const HIT_STAGGER = 8.0
const RAY_LENGTH = 500.0
const MOUSE_ACCEL = 10.0
const FOV_CHANGE = 1.5
const BASE_FOV = 75.0
const MOUSE_Y_MAX = 60.0
const MOUSE_Y_MIN = -80.0

var health: int = 100
var time_since_last_shot = 0.0
var player = null
var cur_ray


# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)
	


func _update_health(value):
	health = health + value
	print("Dummy HP is now: ", health)

func shoot():
	if player:
		var bullet = bullet_scene.instantiate()
		bullet.global_transform = global_transform
		var players = get_tree().get_nodes_in_group("Player") #Gets player from the group
		if players.size() > 0:
			var player = players[0]
			bullet.direction = (player.global_transform.origin - global_transform.origin).normalized()
			
			## Change is here
			var target := Vector3.INF
			var from = bullet.position
			var to = from + (bullet.direction * RAY_LENGTH)
			var space_state := get_world_3d().direct_space_state
			var query := PhysicsRayQueryParameters3D.create(from, to)
			var result := space_state.intersect_ray(query)
			#target = result.position if result else to
			cur_ray = result
			#
			# Additionally added handle_collision and changed the function to check for player
			get_tree().root.add_child(bullet)
			#get_parent().add_child(instance)
			handle_collision()
		else: 
			print("No player found in the 'Player' group")
			


func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		print("Who the fuck is near me")
		player = body


func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		print("Yeah fuck off")
		player = null


func _physics_process(delta):
	if health <= 0:
		print("You killed the dummy")
		queue_free()
		
	if player:
		var direction = (player.global_transform.origin - global_transform.origin).normalized()
		
		#Rotate towards player
		look_at(player.global_transform.origin, Vector3.UP)
		
		#Move towards player
		velocity = direction * speed
		move_and_slide()
		
		var target_rotation = global_transform.basis.get_rotation_quaternion()
		global_transform.basis = Basis(global_transform.basis.slerp(target_rotation, rotation_speed * delta))
		
	time_since_last_shot += delta
	if time_since_last_shot >= shoot_interval:
		shoot()
		time_since_last_shot = 0.0
		
func handle_collision():
	print("Current Dummy Ray: ", cur_ray)
	if cur_ray:
		if cur_ray.collider.is_in_group("Player"):
			cur_ray.collider._update_health(-10)
		print("handled_collison to shoot something")
		return
	print("didnt hit shit LOL")
		
