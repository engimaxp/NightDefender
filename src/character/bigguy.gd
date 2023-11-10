extends CharacterBody3D
class_name BigGuy
#@onready var pivot_point = $PivotPoint

#func _process(delta):
#	pivot_point.rotate_y(delta)
var current_state:Constants.BIGGUY_STATE = Constants.BIGGUY_STATE.IDLE
var is_ready_for_sleep = true
var is_anoyed_by_player = false

@onready var animation_player = $AnimationPlayer
@onready var beehave_tree = $BeehaveTree

@onready var animation_tree = $AnimationTree
@onready var animation_state:AnimationNodeStateMachinePlayback\
	 = animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
@onready var navigation_agent_3d = $NavigationAgent3D
@onready var debug_path = $NavigationAgent3D/debug_path
@export var bed_position_node_path:NodePath
@onready var bed_position_node = get_node(bed_position_node_path)
@export var on_bed_position_node_path:NodePath
@onready var on_bed_position_node = get_node(on_bed_position_node_path)


var target_posiiton:Vector3

var lerp_blend = 0.0
signal arrive_destination

func _ready():
	navigation_agent_3d.navigation_finished.connect(_arrive)

func _arrive():
	arrive_destination.emit()

func _process(delta):
	if not navigation_agent_3d.is_navigation_finished():
		var mesh:ImmediateMesh = debug_path.mesh as ImmediateMesh
		mesh.clear_surfaces()
		mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
		for p in navigation_agent_3d.get_current_navigation_path():
			mesh.surface_add_vertex(p)
		mesh.surface_end()
	if target_posiiton:
		DebugDraw3D.draw_sphere(target_posiiton,0.3,Color.YELLOW)

func _attack():
	animation_tree.set("parameters/attack/request",true)

func _update_target_location(target):
	navigation_agent_3d.target_position = target

func go_to_bed():
	_update_target_location(bed_position_node.global_position)

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_accept"):
		beehave_tree.enabled = not beehave_tree.enabled
	
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

func _physics_process(delta):
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
