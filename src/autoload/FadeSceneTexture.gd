extends TextureRect

signal fade_done

@export var fade_time_seconds:float

var _total_time:float = 0
var _enabled = false

func start():
	self.modulate.a = 1.0
	_enabled = true

func _process(delta:float):
	if not _enabled:
		return
		
	if _total_time >= fade_time_seconds:
		emit_signal("fade_done")
		_enabled = false
		self.material.set("shader_parameter/dissolve_amount", 0)
		_total_time = 0
		return
	
	_total_time += delta
	var fade_amount = _total_time / fade_time_seconds
	self.material.set("shader_parameter/dissolve_amount", fade_amount)
