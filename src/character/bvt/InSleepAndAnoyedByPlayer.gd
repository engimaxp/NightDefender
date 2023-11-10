extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var a = actor as BigGuy
	if a.is_anoyed_by_player and a.current_state == Constants.BIGGUY_STATE.SLEEP:
		return SUCCESS
	else:
		return FAILURE

