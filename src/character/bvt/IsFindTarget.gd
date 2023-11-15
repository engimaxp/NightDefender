extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var a = actor as BigGuy
	if a.is_find_target:
		return SUCCESS
	else:
		return FAILURE

