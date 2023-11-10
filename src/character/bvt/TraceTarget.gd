extends ActionLeaf

var is_start = false
var is_end = false

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var a = actor as BigGuy
	if not is_start:
		is_start = true
		print("start attack around randomly")
		get_tree().create_timer(3.0).timeout.connect(end)
	if is_end:
		clear_status()
		return SUCCESS
	else:
		return RUNNING

func end():
	is_end = true

func interrupt(actor: Node, blackboard: Blackboard) -> void:
	clear_status()

func clear_status():
	is_end = false
	is_start = false
