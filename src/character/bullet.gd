extends CharacterBody3D
const SPEED = 1.5
var direction = Vector3.ZERO

func _physics_process(delta):
	velocity = direction * SPEED
	var m = move_and_slide()
	if m:
		var sc = get_last_slide_collision()
		if sc.get_collider().is_in_group("mosquetto"):
			var b = get_tree().get_first_node_in_group("mosquetto")
			b.hit_by_bat()
			print("hit_by_bat")
			call_deferred("queue_free")
		else:
			call_deferred("queue_free")

