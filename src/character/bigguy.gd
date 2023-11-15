extends CharacterBody3D
class_name BigGuy

var current_state:Constants.BIGGUY_STATE = Constants.BIGGUY_STATE.IDLE
var is_ready_for_sleep = true
var is_anoyed_by_player = false

@onready var animation_player = $AnimationPlayer
@onready var beehave_tree = $BeehaveTree
@onready var head = $Armature_003/GeneralSkeleton/head

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

func _ready():
	flash_light.hide()
	spray.hide()
	tennis_racket.hide()
	if Constants.is_debug:
		is_anoyed_by_player = true
		is_ready_for_sleep = false
	Signals.drink_blood_changed.connect(drink_blood_changed)
	navigation_agent_3d.navigation_finished.connect(_arrive)

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
	
func _process(delta):
	if not navigation_agent_3d.is_navigation_finished():
		var mesh:ImmediateMesh = debug_path.mesh as ImmediateMesh
		mesh.clear_surfaces()
		mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
		for p in navigation_agent_3d.get_current_navigation_path():
			mesh.surface_add_vertex(p)
		mesh.surface_end()
		
func _attack():
	animation_tree.set("parameters/attack/request",true)
	await get_tree().create_timer(2.0,false).timeout

func _update_target_location(target):
	navigation_agent_3d.target_position = target

func _clear_target_location():
	navigation_agent_3d.target_position = Vector3.ZERO

func go_to_bed():
	_update_target_location(bed_position_node.global_position)

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_accept"):
#		random_search_around()
		beehave_tree.enabled = true
#		random_attack()
	
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

func check_mosquetto_insight():
	var mosquetto = get_tree().get_first_node_in_group("mosquetto")
	var direction = mosquetto.global_position - head.global_position
	var dir = global_transform.basis * Vector3.BACK
	DebugDraw3D.draw_arrow_ray(head.global_position,direction,0.4,Color.WHITE)
	DebugDraw3D.draw_arrow_ray(head.global_position,dir,0.4,Color.RED)
	if direction.dot(dir) > 0.4:
		if mosquetto.current_light_value > 0.7:
			print("find target")
			attack_target_position = mosquetto.global_position
			search_target_position = attack_target_position
	
func _physics_process(delta):
	if current_state == Constants.BIGGUY_STATE.IDLE \
		and search_target_position == Vector3.ZERO:
#		check_mosquetto_insight()
		pass
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
	move_and_slide()


func random_search_around():
	flash_light.show()
#	await get_tree().create_timer(1.0,false).timeout
	var bnt = self.global_transform.looking_at(Vector3.FORWARD.rotated(Vector3.UP,randf() * 2.0 * PI))
	var tween2 = create_tween()
	tween2.tween_property(self,"global_transform",bnt,1.0)
	await tween2.finished
#	await get_tree().process_frame
	var candidate_points = get_face_direction_points_for_flash_lights(2.4,2.5,8)
	candidate_points.shuffle()
	var op = flash_light.global_position
	var tween = create_tween()
	for random_point in candidate_points:
		var nb = get_normal_transform(op,random_point,flash_light.global_transform.basis.x,flash_light.global_transform)
		tween.tween_property(flash_light,"global_transform",\
			Transform3D(nb.rotated(-nb.y,PI / 2.0).orthonormalized(),op),1.0)
		tween.tween_interval(1.0)
	await tween.finished
	flash_light.hide()
	return
	
# pp global transform of axis object face direction
# t object origin transform
# origin from point
# target target point
# return basis.z is the final array
func get_normal_transform(origin:Vector3,target:Vector3,pp:Vector3,t:Transform3D): # p1 normal pp need rotated axis
	return t.looking_at(target,(target - origin).cross(pp).normalized(),true).basis

func random_attack():
	if randf() < 0.5:
		await attack_with_smoke()
	else:
		await attack_with_bat()
	return

func attack_with_bat():
	tennis_racket.show()
	await _attack()
	tennis_racket.hide()
	return
	
func attack_with_smoke():
	spray_times_current = 0
	var bnt = self.global_transform.looking_at(Vector3.FORWARD.rotated(Vector3.UP,randf() * 2.0 * PI))
	var tween2 = create_tween()
	tween2.tween_property(self,"global_transform",bnt,1.0)
	await tween2.finished
#	await get_tree().process_frame
	var candidate_points = get_face_direction_points_for_flash_lights(2.4,2.5,2)
	var op = spray.global_position
	var tween = create_tween()
	var random_point = candidate_points[0]
	var nb = get_normal_transform(op,random_point,spray.global_transform.basis.x,spray.global_transform)
	start_spray_transform = nb
	tween.tween_property(spray,"global_transform",\
		Transform3D(nb.rotated(nb.y,PI).orthonormalized(),op),1.0)
	tween.tween_callback(spray.show)
	random_point = candidate_points[1]
	nb = get_normal_transform(op,random_point,spray.global_transform.basis.x,spray.global_transform)
	end_spray_transform = nb
	tween.tween_property(spray,"global_transform",\
		Transform3D(nb.rotated(nb.y,PI).orthonormalized(),op),15.0)
	tween.parallel().tween_property(self,"smoke_attack_progress",1.0,15.0).from(0.0)
	await tween.finished
	spray.hide()
	return

const spray_times_total:int = 5
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
