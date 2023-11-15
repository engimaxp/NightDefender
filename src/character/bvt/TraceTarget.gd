extends ActionLeaf

var is_arrive = false
var is_start = false
var is_lost_target = false

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var a = actor as BigGuy
	if not is_start:
		is_start = true
		if not a.arrive_destination.is_connected(arrive):
			a.arrive_destination.connect(arrive)
		a.trace_target(true)
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
	a.trace_target(false)
	is_arrive = false
	is_start = false
	is_lost_target = false
