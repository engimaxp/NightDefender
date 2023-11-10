extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var a = actor as BigGuy
	if a.is_ready_for_sleep and a.current_state == Constants.BIGGUY_STATE.IDLE:
		return SUCCESS
	else:
		return FAILURE

