extends ActionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var a = actor as BigGuy
	if not a.is_find_target:
		a.attack_target_position = Vector3.ZERO
		a.search_target_position = Vector3.ZERO
		a.mark_display("hide")
	var mos = get_tree().get_first_node_in_group("mosquetto")
	if not mos.is_processing():
		a.is_anoyed_by_player = false
		a.is_ready_for_sleep = true
	return SUCCESS
