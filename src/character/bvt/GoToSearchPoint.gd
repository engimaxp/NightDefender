extends ActionLeaf

var is_arrive = false
var is_start = false

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var a = actor as BigGuy
	if not is_start:
		is_start = true
		var path = (a.search_path as Path3D)
		var curve_length = path.curve.get_baked_length()
		var rp = path.curve.sample_baked(randf_range(0.0,curve_length))
		if not a.arrive_destination.is_connected(arrive):
			a.arrive_destination.connect(arrive)
		a._update_target_location(rp)
	if is_arrive:
		clear_status(a)
#		a._clear_target_location()
		return SUCCESS
	else:
		return RUNNING

func arrive():
	if is_start:
		is_arrive = true
				
func interrupt(actor: Node, blackboard: Blackboard) -> void:
	clear_status(actor)

func clear_status(a):
	if a.arrive_destination.is_connected(arrive):
		a.arrive_destination.disconnect(arrive)
	is_arrive = false
	is_start = false
