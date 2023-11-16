extends Node3D

#const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var velocity = Vector3.ZERO
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var is_gravity_reverse = false
@onready var timer = $Timer

func is_on_floor():
	return self.global_position.y <= 0.2
	
func is_on_ceiling():
	return self.global_position.y >= 4.0

func _physics_process(delta):
	# Add the gravity.
	if not is_gravity_reverse:
		if not is_on_floor():
			velocity.y -= gravity * delta * 0.001
		else:
			if timer.is_stopped():
				timer.start()
			velocity.y = 0
	else:
		if not is_on_ceiling():
			velocity.y += gravity * delta * 0.001
		else:
			if timer.is_stopped():
				timer.start()
			velocity.y = 0
	self.global_position += velocity * delta

@onready var fog_volume = $FogVolume

func _ready():
	await fog_volume.start_fog()

func _on_timer_timeout():
	await fog_volume.stop_fog()
	var tween = create_tween()
	tween.tween_property(self,"scale",Vector3.ONE * (0.01),1.0)
	tween.tween_callback(self.exit_scene)
	tween.tween_callback(self.queue_free)

func exit_scene():
	sig_exit_scene.emit()

signal sig_exit_scene

func _on_area_3d_body_entered(body):
	if body.is_in_group("mosquetto"):
		body.in_smoke_cloud(self)


func _on_area_3d_body_exited(body):
	if body.is_in_group("mosquetto"):
		body.out_smoke_cloud(self)
