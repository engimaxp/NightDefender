extends ActionLeaf

var is_arrive = false
var is_start_go_to_bed = false

func _arrive(a):
	var tween = create_tween()
	var forward = Vector3.LEFT
	var lookat_basis = Basis.looking_at(forward)
	var original_scale = a.get_scale()
	var nt = Transform3D(lookat_basis, a.global_position)
	nt.scaled(original_scale);
	tween.tween_property(a,"global_transform",nt,0.5)
	tween.tween_property(a,"global_position",a.on_bed_position_node.position,0.2)
	await tween.finished
	is_arrive = true

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var a = actor as BigGuy
	if not is_start_go_to_bed:
		is_start_go_to_bed = true
		a.go_to_bed()
	if not a.arrive_destination.is_connected(_arrive):
		a.arrive_destination.connect(_arrive.bind(actor))

	if not is_arrive:
		return RUNNING
	else:
		var anit:AnimationTree = a.animation_tree as AnimationTree
		var anip:AnimationPlayer = a.animation_player as AnimationPlayer
		if anit.get("parameters/Transition/current_state") != "sleep" and \
			anit.get("parameters/Transition/current_state") != "to_sleep":
			anit.set("parameters/TimeSeek/seek_request",5.7)
			anit.set("parameters/Transition/transition_request","to_sleep")
			return RUNNING
		else:
			if anit.get("parameters/Transition/current_state") == "sleep":
				a.current_state = Constants.BIGGUY_STATE.SLEEP
				Signals.bigguy_sleep.emit()
				clear_status()
				return SUCCESS
			else:
				return RUNNING
				
func interrupt(actor: Node, blackboard: Blackboard) -> void:
	clear_status()
		
func clear_status():
	is_arrive = false
	is_start_go_to_bed = false
