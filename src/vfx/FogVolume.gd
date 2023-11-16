extends FogVolume
@export var density_path: String = 'density'
@export var smoke_density: float = 8.0

@export var spawn_time: float = 1.0
@export var fade_time: float = 5.0

func _ready():
	material = material.duplicate(true)
	material.set(density_path, 0.0)
	
func start_fog():
	var tween = get_tree().create_tween()
	tween.tween_property(self.material, density_path, smoke_density, spawn_time)
	await tween.finished

func stop_fog():
	var tween = get_tree().create_tween()
	tween.tween_property(self.material, density_path, 0.0, fade_time).set_ease(Tween.EASE_IN)
	await tween.finished
