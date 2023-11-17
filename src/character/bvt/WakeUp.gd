extends ActionLeaf

var is_wake_up = false

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var a = actor as BigGuy
	var anit:AnimationTree = a.animation_tree as AnimationTree
	var anip:AnimationPlayer = a.animation_player as AnimationPlayer
	if a.current_state == Constants.BIGGUY_STATE.IDLE:
		clear_status()
		return SUCCESS
	if a.current_state != Constants.BIGGUY_STATE.WAKEUP:
		a.current_state = Constants.BIGGUY_STATE.WAKEUP
		if anit.get("parameters/Transition/current_state") == "sleep":
			anit.set("parameters/Transition/transition_request","wake_up")
			if not is_wake_up:
				is_wake_up = true
				a.is_ready_for_sleep = false
				a.mark_display("none")
				var tween = create_tween()
				tween.tween_property(a,"global_position",a.bed_position_node.position,1.5)
			return RUNNING
	if anit.get("parameters/Transition/current_state") == "idle":
		a.current_state = Constants.BIGGUY_STATE.IDLE
		clear_status()
		return SUCCESS
	return RUNNING
				
func interrupt(actor: Node, blackboard: Blackboard) -> void:
	clear_status()

func clear_status():
	is_wake_up = false
