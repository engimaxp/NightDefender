extends CharacterBody3D
class_name BigGuy

var current_state:Constants.BIGGUY_STATE = Constants.BIGGUY_STATE.IDLE
var is_ready_for_sleep = true
var is_anoyed_by_player = false
@onready var head_aware = %HeadAware
@onready var ear_aware = %EarAware

@onready var animation_player = $AnimationPlayer
@onready var tree = $BeehaveTree
@onready var head = $Armature_003/GeneralSkeleton/head
@export var light_level_cautious = 0.0
@onready var animation_tree = $AnimationTree
@onready var animation_state:AnimationNodeStateMachinePlayback\
	 = animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
@onready var navigation_agent_3d = $NavigationAgent3D
@onready var debug_path = $NavigationAgent3D/debug_path
@export var bed_position_node_path:NodePath
@onready var bed_position_node = get_node(bed_position_node_path)
@export var on_bed_position_node_path:NodePath
@onready var on_bed_position_node = get_node(on_bed_position_node_path)
@export var search_path:Path3D
@onready var tennis_racket = %TennisRacket
@onready var spray = %Spray
@onready var bat_hit_area = $BatHitArea

@onready var flash_light = %flashLight
var attack_target_position:Vector3
var search_target_position:Vector3
var target_posiiton:Vector3

var lerp_blend = 0.0
signal arrive_destination
@onready var status_mark = $StatusMark
@onready var loop_tween = $LoopTween
@onready var loop_tween2 = $LoopTween2
@onready var status_label_2d = %StatusLabel2D
@onready var sleep_mark = $SleepMark

func _ready():
	flash_light.hide()
	spray.hide()
	tennis_racket.hide()
	status_mark.text = ""
	sleep_mark.text = ""
	status_label_2d.text = ""
	if Constants.is_debug:
		is_anoyed_by_player = true
		is_ready_for_sleep = false
	Signals.drink_blood_changed.connect(drink_blood_changed)
	navigation_agent_3d.navigation_finished.connect(_arrive)

func mark_display(mark):
	if mark == "question":
		status_mark.text = "?"
		status_mark.modulate = Color(0.95, 0.95, 0.19, 1)
		status_label_2d.text = status_mark.text
		status_label_2d["theme_override_colors/font_color"] = status_mark.modulate
	elif mark == "sleep":
		loop_tween.start(sleep_mark,["text"],func(tween):
			tween.tween_property(sleep_mark,"text","z",1.0)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(sleep_mark,"text","zz",1.0)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(sleep_mark,"text","zzZ",1.0)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		)
		status_label_2d["theme_override_colors/font_color"] = Color.WHITE
		loop_tween2.start(status_label_2d,["text"],func(tween):
			tween.tween_property(status_label_2d,"text","z",1.0)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(status_label_2d,"text","zz",1.0)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(status_label_2d,"text","zzZ",1.0)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		)
	elif mark == "alert":
		status_mark.text = "!"
		status_mark.modulate = Color.ORANGE_RED
		status_label_2d.text = status_mark.text
		status_label_2d["theme_override_colors/font_color"] = status_mark.modulate
	else:# hide_mark
		status_mark.text = ""
		sleep_mark.text = ""
		status_label_2d.text = ""
		loop_tween.stop()
		loop_tween2.stop()

func drink_blood_changed(v):
	if v > 5:
		is_anoyed_by_player = true
		Signals.bigguy_awake.emit()

func _arrive():
	arrive_destination.emit()

func get_face_direction_points_for_flash_lights(radius,forward,count):
	var direction = self.global_transform.basis * Vector3.BACK
	var op = flash_light.global_position
	var r_count = count
	var rad_inc = 2.0 * PI / r_count
	var r = self.global_transform.basis * Vector3.LEFT * radius
	var points = []
	for x in r_count:
		var rp = (op + direction * forward) + r.rotated(direction.normalized(),x * rad_inc)
		points.append(rp)
	return points

@onready var condition_label = $VBoxContainer/ConditionLabel
@onready var action_label = $VBoxContainer/ActionLabel


func _process(delta):
#	if not navigation_agent_3d.is_navigation_finished():
#		var mesh:ImmediateMesh = debug_path.mesh as ImmediateMesh
#		mesh.clear_surfaces()
#		mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
#		for p in navigation_agent_3d.get_current_navigation_path():
#			mesh.surface_add_vertex(p)
#		mesh.surface_end()
	
	
	if tree.get_last_condition():
		condition_label.text = str(tree.get_last_condition(), " -> ", tree.get_last_condition_status())
	else:
		condition_label.text = "no condition"

	if tree.get_running_action():
		action_label.text = str(tree.get_running_action(), " -> RUNNING")
	else:
		action_label.text = "no running action"
	
func _attack():
	animation_tree.set("parameters/attack/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await get_tree().create_timer(2.0,false).timeout

func _update_target_location(target):
	navigation_agent_3d.target_position = target

func _clear_target_location():
	navigation_agent_3d.target_position = Vector3.ZERO

func go_to_bed():
	flash_light.hide()
	_update_target_location(bed_position_node.global_position)

func _unhandled_input(event):
#	if Input.is_action_just_pressed("ui_accept"):
#		attack_with_grenade()
#		random_search_around()
#		tree.enabled = true
#		random_attack()
#		Signals.game_over.emit()
	
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_MASK_RIGHT:
		var camera = get_viewport().get_camera_3d() as Camera3D
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_length = 100
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * ray_length
		var space = get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = from
		ray_query.to = to
		ray_query.set_collide_with_areas(false)
		ray_query.set_collide_with_bodies(true)
		ray_query.collision_mask = collision_mask
		var result = space.intersect_ray(ray_query)
#		print(result)
		if !result.is_empty():
			target_posiiton = result.position
			_update_target_location(result.position)
				

func _turn_to_position(p): 
	var target_v = self.global_position - p + self.global_position
	target_v.y = 0
	var forward = target_v
	var lookat_basis = Basis.looking_at(forward)
	var original_scale = get_scale();
	var nt = Transform3D(lookat_basis, self.global_position);
	nt.scaled(original_scale);
	
#	var current_v = self.global_transform * Vector3.BACK
	var no_angle = lookat_basis.get_rotation_quaternion().is_equal_approx(basis.get_rotation_quaternion())
	if not no_angle:
		var tween = create_tween()
		tween.tween_property(self,"global_transform",nt,0.2)
		await tween.finished
	return

func get_mosqueto_from_array(array):
	for a in array:
		if a.is_in_group("mosquetto"):
			return a
	return null
	
func check_mosquetto_insight():
	var mosquetto = get_tree().get_first_node_in_group("mosquetto")
	var direction = mosquetto.global_position - head.global_position
	var dir = global_transform.basis * Vector3.BACK
#	DebugDraw3D.draw_arrow_ray(head.global_position,direction,0.4,Color.WHITE)
#	DebugDraw3D.draw_arrow_ray(head.global_position,dir,0.4,Color.RED)
	var a = get_mosqueto_from_array(head_aware.get_overlapping_bodies())
	var b = get_mosqueto_from_array(ear_aware.get_overlapping_bodies())
	var temp_flag = false
	if direction.dot(dir) > 0.2 and direction.length() <= 6.0:
		if mosquetto.current_light_value > light_level_cautious:
			temp_flag = true
	if a != null:
		temp_flag = true
	if b != null and b.is_in_air():
		temp_flag = true
	is_find_target = temp_flag
	if is_find_target:
		attack_target_position = mosquetto.global_position
		var atp = Vector3(attack_target_position.x,global_position.y,attack_target_position.z)
		search_target_position = atp + (global_position - atp).normalized() * 0.5
	
func _physics_process(delta):
	
#	DebugDraw3D.draw_sphere(search_target_position,0.3,Color.RED)
#	DebugDraw3D.draw_sphere(attack_target_position,0.2,Color.YELLOW)
	if current_state == Constants.BIGGUY_STATE.IDLE:
		check_mosquetto_insight()
		if is_tracing_target:
			_update_target_location(search_target_position)
		
#		if attack_target_position != null
	var current_position = global_position
	var next_position = current_position
	var direction = Vector3.ZERO
	
	if navigation_agent_3d.is_navigation_finished():
		direction = Vector3.ZERO
	else:
		next_position = navigation_agent_3d.get_next_path_position()
		direction = (next_position - current_position).normalized()
		self.rotation.y = lerp_angle(self.rotation.y,atan2(direction.x,direction.z),delta * 4)
	
	if direction == Vector3.ZERO:
		lerp_blend = lerp(lerp_blend,0.0,delta * 7.0)
	else:
		lerp_blend = lerp(lerp_blend,1.0,delta * 7.0)
	animation_tree.set("parameters/move_blend/blend_amount",lerp_blend)
	var currentRotation = global_transform.basis.get_rotation_quaternion()
	velocity = ((currentRotation.normalized() * animation_tree.get_root_motion_position()) / delta)
	velocity.y = 0
	move_and_slide()

var is_tracing_target = false
			
var is_find_target = false:
	set(v):
		var diff = is_find_target != v
		is_find_target = v
		if is_find_target and diff: 
#			print(tree.get_last_condition().name)
			if current_state == Constants.BIGGUY_STATE.IDLE\
			and tree.enabled and tree.get_running_action().name == "SearchAroundRandom":
				print("tree.interupt()")
				tree.interrupt()

func trace_target(is_true):
	is_tracing_target = is_true


signal search_complete

func fallback_search_around():
	flash_light.hide()
	if animation_tree.get("parameters/search/active"):
		animation_tree.set("parameters/search/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	search_complete.emit()
	for ti in range(tween_registed.size() -1 ,-1,-1):
		if tween_registed[ti] != null and (tween_registed[ti] as Tween).is_running():
			(tween_registed[ti] as Tween).stop()
			tween_registed.remove_at(ti)
	
var tween_registed = []

func random_search_around():
	flash_light.show()
#	await get_tree().create_timer(1.0,false).timeout
	var bnt = self.global_transform.looking_at(Vector3.FORWARD.rotated(Vector3.UP,randf() * 2.0 * PI))
	var tween2 = create_tween()
	tween2.tween_property(self,"global_transform",bnt,1.0)
	tween_registed.append(tween2)
	await tween2.finished
	tween_registed.erase(tween2)
	animation_tree.set("parameters/search/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await search_complete
	return
	
# pp global transform of axis object face direction
# t object origin transform
# origin from point
# target target point
# return basis.z is the final array
func get_normal_transform(origin:Vector3,target:Vector3,pp:Vector3,t:Transform3D): # p1 normal pp need rotated axis
	return t.looking_at(target,(target - origin).cross(pp).normalized(),true).basis

func random_attack():
	var r = randf()
	if r < 0.3:
		await attack_with_smoke()
	elif r < 0.7:
		await attack_with_grenade()
	else:
		await attack_with_bat()
	return

func attack_target():
	var r = randf()
	if r < 0.3:
		await attack_with_smoke(attack_target_position)
	elif r < 0.7:
		await attack_with_grenade()
	else:
		await attack_with_bat(attack_target_position)
	return

func attack_with_bat(p = null):
	flash_light.hide()
	tennis_racket.show()
	_bat_hit(p)
	await _attack()
	tennis_racket.hide()
	flash_light.show()
	return

func _bat_hit(p = null):
	if p != null:
		bat_hit_area.global_position = p
	else:
		bat_hit_area.position = Vector3(0,1,1)
	await get_tree().create_timer(1.2,false).timeout
	for b in bat_hit_area.get_overlapping_bodies():
		if b.is_in_group("mosquetto"):
			b.hit_by_bat()

@onready var grenade = %Grenade
signal throw_complete

func attack_with_grenade():
	grenade.show()
	grenade.start_emitting()
	animation_tree.set("parameters/throw/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await throw_complete
	
const GRENADE = preload("res://src/character/grenade.tscn")

func throw_proj():
	for i in 3:
		var g = GRENADE.instantiate()
		get_tree().current_scene.add_child(g)
		g.timer_change(randf_range(2.0,3.0))
		g.transform = grenade.global_transform
		g.set_deferred("freeze",false)
		g.start_emitting()
		(g as RigidBody3D).apply_central_impulse(
			global_transform.basis * Vector3.BACK * (randf() * 7.0)
		)
	grenade.hide()
	grenade.stop_emitting()
	throw_complete.emit()
	
func attack_with_smoke(p = null):
	spray_times_current = 0
	var bnt
	if p == null:
		bnt = self.global_transform.looking_at(Vector3.FORWARD.rotated(Vector3.UP,randf() * 2.0 * PI))
	else:
		bnt = self.global_transform.looking_at(Vector3(p.x,self.global_position.y,p.z),Vector3.UP)
		bnt = Transform3D(bnt.basis.rotated(Vector3.UP,PI).orthonormalized(),self.global_position)
	var tween2 = create_tween()
	tween2.tween_property(self,"global_transform",bnt,1.0)
	await tween2.finished
#	await get_tree().process_frame
	var candidate_points = get_face_direction_points_for_flash_lights(2.4,2.5,2)
	var op = spray.global_position
	flash_light.hide()
	spray.show()
	animation_tree.set("parameters/search/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	var random_point = candidate_points[0]
	var nb = get_normal_transform(op,random_point,spray.global_transform.basis.x,spray.global_transform)
	start_spray_transform = nb
	random_point = candidate_points[1]
	nb = get_normal_transform(op,random_point,spray.global_transform.basis.x,spray.global_transform)
	end_spray_transform = nb
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(self,"smoke_attack_progress",1.0,2.0).from(0.0)
	await search_complete
	spray.hide()
	flash_light.show()
	return

const spray_times_total:int = 3
var spray_times_current:int = 0
var start_spray_transform
var end_spray_transform
const distance_between_smoke = 0.8
var smoke_attack_progress:float = 0.0:
	set(val):
		smoke_attack_progress = val
		if is_instance_valid(spray):
			var ct = int(smoke_attack_progress / (1.0 / spray_times_total))
			if ct > spray_times_current:
				for i in (ct - spray_times_current):
					_spawn_spray_smoke(spray_times_current + i)
				spray_times_current = ct
				
func _spawn_spray_smoke(i):
	var nt = (start_spray_transform as Transform3D).interpolate_with(end_spray_transform,float(i) / float(spray_times_total))
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state as PhysicsDirectSpaceState3D
	var params2 = PhysicsRayQueryParameters3D.new()
	params2.set_collide_with_bodies(true)
	params2.set_collide_with_areas(false)
	params2.collision_mask = 1
	params2.from = spray.get_node("SmokeRayOrigin").global_position
	params2.to = params2.from + nt.basis.z * 10.0
	var result = space.intersect_ray(params2)
	if result != null and not result.is_empty():
		var total_v = (result.position - params2.from)
		var total_length = total_v.length()
		var v = total_v.normalized()
		for j in 3:
			var p = params2.from + v * (j + 1) * distance_between_smoke
			Signals.spawn_smoke.emit(p)
