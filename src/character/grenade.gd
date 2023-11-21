extends RigidBody3D

const BULLET = preload("res://src/character/bullet.tscn")

func timer_change(tc):
	$Timer.wait_time = tc
	$Timer.start()

@export var is_dummy:bool = false

func _ready():
	if is_dummy:
		gpu_particles_3d.local_coords = true
		
@onready var gpu_particles_3d = $GPUParticles3D

func start_emitting():
	gpu_particles_3d.emitting = true
func stop_emitting():
	gpu_particles_3d.emitting = false

func _on_timer_timeout():
	if self.freeze:
		return
	explode()
	self.queue_free()

func explode():
	for p in get_semi_sephere_glob():
		var bullet = BULLET.instantiate()
		bullet.position = self.global_position + p * 0.3
		bullet.direction = p
		get_tree().current_scene.add_child(bullet)

func get_semi_sephere_glob():
	var points = []
	for x in 8:
		var xx = Vector3.UP.rotated(Vector3.LEFT,(PI /  20.0) * (x + 1))
		for y in 8:
			var shift = 0 if x % 2 == 0 else 1
			var yy = xx.rotated(Vector3.UP,(PI / 8.0) * shift + (PI / 4.0) * y)
			points.append(yy)
	return points
