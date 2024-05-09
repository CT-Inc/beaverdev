extends Node

const GAME_TITLE := "BeaverGame"

const MOUSE_SENS: float = 0.1

const FRICTION: float = 4

const ACCEL: float = 12
const ACCEL_AIR: float = 40

const GRAVITY := 40.0

const TOP_SPEED_GROUND: float = 15
const TOP_SPEED_AIR: float = 2.5
const LIN_FRICTION_SPEED: float = 10
const JUMP_FORCE: float = 14

const RAY_LENGTH: float = 1000.0

const MOUSE_Y_MIN: float = -80.0
const MOUSE_Y_MAX: float = 60.0

const MOUSE_ACCEL_X: float = 10.0
const MOUSE_ACCEL_Y: float = 10.0

var _root_node: Node

@onready var _scene_bullet := ResourceLoader.load("res://src/Bullet/Bullet.tscn")
@onready var _scene_bullet_glow := ResourceLoader.load("res://src/BulletGlow/BulletGlow.tscn")
@onready var _scene_bullet_spark := ResourceLoader.load("res://src/BulletSpark/BulletSpark.tscn")

func create_bullet(parent, start_pos, target_pos, bullet_type):
	var bullet = _scene_bullet.instantiate()
	print(bullet)
	parent.add_child(bullet)
	bullet.global_transform.origin = start_pos
	Global.safe_look_at(bullet, target_pos)
	bullet.start(bullet_type)
	
func create_bullet_spark(pos):
	var spark = _scene_bullet_spark.instantiate()
	Global._root_node.add_child(spark)
	spark.global_transform.origin = pos
	
func safe_look_at(spatial: Node3D, target: Vector3):
	var origin := spatial.global_transform.origin
	var v_z := (origin - target).normalized()
	
	if origin == target:
		return
		
	var up := Vector3.ZERO
	for entry in [Vector3.UP, Vector3.RIGHT, Vector3.BACK]:
		var v_x : Vector3 = entry.cross(v_z).normalized()
		if v_x.length() != 0:
			up = entry
			break
			
	if up != Vector3.ZERO:
		spatial.look_at(target, up)

enum Layers {
	terrain,
	item,
	player,
}

enum BulletType {
	_308,
}

const DB = {
	"Bullets" : {
		BulletType._308 : {
			"mass" : 0.018,
			"speed" : 1219.0,
			"max_distance" : 500.0,
		}
	}
}
