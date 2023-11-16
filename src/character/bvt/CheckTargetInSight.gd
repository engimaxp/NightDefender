extends ActionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var a = actor as BigGuy
	if not a.is_find_target:
		a.attack_target_position = Vector3.ZERO
		a.search_target_position = Vector3.ZERO
	return SUCCESS
