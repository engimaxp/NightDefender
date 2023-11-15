extends Node3D

const smoke_instance = preload("res://src/vfx/smoke.tscn")

func _ready():
	Signals.spawn_smoke.connect(spawn_smoke)
	
func spawn_smoke(pos):
	var s = smoke_instance.instantiate()
	add_child(s)
	s.global_position = pos
