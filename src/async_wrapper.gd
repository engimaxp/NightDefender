extends RefCounted

signal complete(returns)

func execute(f:Callable,param = null):
	if param == null:
		var result = await f.call()
		complete.emit(result)
	else:
		var result = await f.callv(param)
		complete.emit(result)
