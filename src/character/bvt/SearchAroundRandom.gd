extends ActionLeaf

var is_start = false
var is_end = false

const AsyncTask = preload("res://src/async_wrapper.gd")
var task = null

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var a = actor as BigGuy
	if not is_start:
		is_start = true
		if task == null:
			task = AsyncTask.new()
			task.execute(a.random_search_around)
			task.complete.connect(end)
	
	if is_end:
		clear_status()
		return SUCCESS
	else:
		return RUNNING

func end(_p):
	if is_start:
		is_end = true

func interrupt(actor: Node, blackboard: Blackboard) -> void:
	var a = actor as BigGuy
	a.fallback_search_around()
	clear_status()

func clear_status():
	is_end = false
	is_start = false
	task = null
