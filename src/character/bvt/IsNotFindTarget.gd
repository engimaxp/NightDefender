extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var a = actor as BigGuy
	if a.attack_target_position == null or a.attack_target_position == Vector3.ZERO:
		return SUCCESS
	else:
		return FAILURE

