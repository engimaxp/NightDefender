extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var a = actor as BigGuy
	var rtimes = _blackboard.get_value(Constants.BVT_SEARCH_TIME,Constants.BVT_SEARCH_TIME_INITIAL)
	print("rtimes:",rtimes)
	if rtimes > 0:
		_blackboard.set_value(Constants.BVT_SEARCH_TIME,rtimes - 1)
		return SUCCESS
	else:
		_blackboard.set_value(Constants.BVT_SEARCH_TIME,Constants.BVT_SEARCH_TIME_INITIAL)
		a.is_anoyed_by_player = false
		a.is_ready_for_sleep = true
		return FAILURE
