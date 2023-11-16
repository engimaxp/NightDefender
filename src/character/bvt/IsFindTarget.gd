extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var a = actor as BigGuy
	if a.search_target_position != null and a.search_target_position != Vector3.ZERO:
		return SUCCESS
	else:
		return FAILURE

