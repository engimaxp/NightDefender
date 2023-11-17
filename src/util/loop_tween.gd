extends Node
class_name LoopTween
var tween
var origin_value_dic = {}
var target

func start(p_target,prop_array,tween_animation:Callable):
	if tween == null:
		target = p_target
		tween = create_tween().set_loops()
		tween.bind_node(p_target)
		for prop in prop_array:
			origin_value_dic[prop] = target.get(prop)
		tween_animation.call(tween)

func stop():
	if tween != null:
		if tween.is_running():
			tween.stop()
		tween = null
		for k in origin_value_dic.keys():
			if is_instance_valid(target):
				target.set(k,origin_value_dic[k])
