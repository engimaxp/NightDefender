extends Node3D

const smoke_instance = preload("res://src/vfx/smoke.tscn")
@onready var animation_tree = $AnimationTree
@onready var hit_effect = $HitEffect
@onready var heal_effect = $HealEffect
const green = Color("7ce349")
const red = Color(0.89, 0.1958, 0.1958, 1)

func _ready():
	trigger_vfx("null",false)
	Signals.spawn_smoke.connect(spawn_smoke)
	Signals.trigger_vfx.connect(trigger_vfx)
	
func spawn_smoke(pos):
	var s = smoke_instance.instantiate()
	s.is_gravity_reverse = (randf() < 0.5)
	add_child(s)
	s.global_position = pos

func trigger_vfx(key,is_start):
	heal_effect.hide()
	hit_effect.hide()
	animation_tree.play("RESET")
	if is_start:
		if key == "heal":
			heal_effect.material["shader_parameter/tint_color"] = green
			heal_effect.show()
			animation_tree.play("heal")
		elif key == "poison":
			heal_effect.material["shader_parameter/tint_color"] = red
			heal_effect.show()
			animation_tree.play("heal")
		elif key == "hit":
			hit_effect.show()
			animation_tree.play("hit")
