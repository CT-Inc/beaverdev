extends Node3D

const SPEED = 100.0

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D

var direction = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0, 0 , -SPEED) * delta
	if ray.is_colliding():
		mesh.visible = false
		particles.emitting = true
		ray.enabled = true
		if ray.get_collider().is_in_group("enemy"):
			print("hit enemy")
		#Checking collision with player, this is gonna be used for the dummy
		if ray.get_collider().is_in_group("Player"):
			print("hit player")
			ray.get_collider().call("update_health", -10)
			#commenting this out for now because trying to see if weapons-manager
			# can handle the collisions, not the individual bullets
			# since we are doing hitscan, the bullet is just visual effect and a
			# doesnt actually do anything, the ray is invisible
			# annd the bullet is just trying to mimic it
			# also this isnt as reliable as the other ray for some reason.
			#ray.get_collider().hit()
		await get_tree().create_timer(1.0).timeout
		queue_free()
	
func _on_timer_timeout():
	queue_free()
