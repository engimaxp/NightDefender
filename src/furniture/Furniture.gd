extends Node3D

func _ready():
	Signals.bigguy_awake.connect(bigguy_awake)
	Signals.bigguy_sleep.connect(bigguy_sleep)
	
func bigguy_awake():
	for l in get_tree().get_nodes_in_group("light"):
		l.show()

func bigguy_sleep():
	for l in get_tree().get_nodes_in_group("light"):
		l.hide()
