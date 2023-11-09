extends CharacterBody3D

const SPEED = 2.0
const CRAW_SPEED = 0.1
const JUMP_VELOCITY = 3.0
const LOOK_SENS  := 0.5

const MOSQUETTO_HOLOGRAM_GROUP = "mosquetto_hologram"
const MOSQUETTO_HOLOGRAM_SCENE = preload("res://src/character/mosquetto_hologram.tscn")
@onready var animation_tree = $AnimationTree

@onready var camera = $CameraController

@onready var sub_viewport := $SubViewport
@onready var light_detection := $SubViewport/LightDetection

@onready var sub_viewport_2 = $SubViewport2
@onready var light_detection2 = $SubViewport2/LightDetection
@onready var ray_cast_3d = $Armature/RayCast3D

@onready var texture_rect := $TextureRect
@onready var texture_rect_2 = $TextureRect2

@onready var color_rect := $ColorRect
@onready var light_level := $LightLevel
@onready var light_detect_timer = $LightDetectTimer
var target_light_value:float = 0.0
var current_light_value:float = 0.0
@export var shape : Shape3D
# Get the gravity from the project settings to be synced with RigidBody nodes
#var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_delta : Vector2
var hologram
var is_landable: = false
var is_landed: = false
var is_landing: = false
var is_taking_of: = false

var target_land_basis:Basis
var target_land_position:Vector3

func _ready() -> void:
	hologram = get_hologram()
	hologram.hide()
#	camera = get_viewport().get_camera_3d()
	# Capture mouse cursor for mouse look
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Make SubViewport render lighting only
#	sub_viewport.debug_draw = 2
#	sub_viewport_2.debug_draw = 2
	light_detect_timer.timeout.connect(calculate_light)

func _physics_process(delta: float) -> void:
	if is_landing:
		return
	if is_taking_of:
		return
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	input_dir = -input_dir
	if is_landed:
		if ray_cast_3d.is_colliding():
			input_dir.y = clamp(input_dir.y,0,1)
		else:
			input_dir.y = 0
		input_dir.x = 0
	
	var y_input := Input.get_axis("dive","rise")
	if is_landed:
		y_input = 0
	var direction := (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var spd = SPEED if not is_landed else CRAW_SPEED
	if direction or y_input:
		velocity.x = direction.x * spd
		velocity.z = direction.z * spd
		velocity.y = y_input * spd + direction.y * spd
	else:
		velocity.x = move_toward(velocity.x, 0, spd)
		velocity.z = move_toward(velocity.z, 0, spd)
		velocity.y = move_toward(velocity.y, 0, spd)
	if is_landed:
		if input_dir != Vector2.ZERO:
			if animation_tree.get("parameters/Transition/current_state") != "move":
				animation_tree.set("parameters/Transition/transition_request","move")
		else:
			if animation_tree.get("parameters/Transition/current_state") != "land":
				animation_tree.set("parameters/Transition/transition_request","land")
		
	move_and_slide()
	detect_collide()
	
func detect_collide():
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state as PhysicsDirectSpaceState3D
	var params: = PhysicsShapeQueryParameters3D.new()
	params.collision_mask = self.collision_mask
	params.set_shape(shape)
	params.transform = transform
	params.transform.origin = self.global_position
	params.set_exclude([self.get_rid()])
	var collide_result = space.collide_shape(params,1)
	is_landable = false
	if collide_result != null and not collide_result.is_empty():
		var ray_intersect = (collide_result[0] - self.global_position) * 1.1
		var params2 = PhysicsRayQueryParameters3D.new()
		params2.set_collide_with_bodies(true)
		params2.set_collide_with_areas(false)
		params2.collision_mask = self.collision_mask
		params2.from = self.global_position
		params2.to = self.global_position + ray_intersect
		var result = space.intersect_ray(params2)
		if result != null and not result.is_empty():
			is_landable = true
			hologram.transform = Transform3D(get_normal_transform(result.normal,Vector3.UP,Vector3.FORWARD),\
				result.position)
			target_land_position = result.position
			target_land_basis = hologram.global_transform.basis
#			DebugDraw3D.draw_arrow_ray(result.position,result.normal,0.15,Color.REBECCA_PURPLE)
#		DebugDraw3D.draw_sphere(collide_result[0],0.05,Color.WHITE)
	hologram.visible = is_landable and not is_landed

func get_normal_transform(p1:Vector3,pp:Vector3,pp2:Vector3): # p1 normal pp need rotated axis
	var angle = pp.angle_to(p1)
	if angle == 0 or pp2.cross(p1) == Vector3.ZERO:
		angle = pp2.angle_to(p1)
		var p2 = pp2.cross(p1)
		return Basis(p2.normalized(),angle)
	else:
		var p2 = pp.cross(p1)
		return Basis(p2.normalized(),angle)

#func _decide_another_point():
#	Vector3.UP

func _process(delta: float) -> void:
	# Mouse look
	if not is_landing:
		if mouse_delta != Vector2.ZERO:
			camera.rotate_x(mouse_delta.y * LOOK_SENS * delta) # Rotate the camera around X axis using mouse delta
			camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2) # Clamp camera X rotation between -90 and 90 degrees
			rotate((self.global_transform.basis * Vector3.UP).normalized(),-mouse_delta.x * LOOK_SENS * delta) # Rotate the player around Y axis using mouse delta
	
	
	mouse_delta = Vector2.ZERO # Reset mouse delta so that only the last frame's relative motion is used
	current_light_value = move_toward(target_light_value,target_light_value,delta)
	light_level.tint_progress.a = current_light_value # Also tint the progress texture with the above
	
	
	if is_landing:
		if self.global_transform.basis.is_equal_approx(target_land_basis) and \
			self.global_position.is_equal_approx(target_land_position):
			landed()
		elif not self.global_transform.basis.is_equal_approx(target_land_basis):
			self.global_transform.basis = Basis(self.global_transform.basis.get_rotation_quaternion().slerp(target_land_basis.get_rotation_quaternion(),delta*10))
		elif not self.global_position.is_equal_approx(target_land_position):
			self.global_position = lerp(self.global_position,target_land_position,delta*10)
func calculate_light():
	# Light detection
	light_detection.global_position = global_position # Make light detection follow the player
	light_detection2.global_position = global_position # Make light detection follow the player
	var texture = sub_viewport.get_texture() # Get the ViewportTexture from the SubViewport
	texture_rect.texture = texture # Display this texture on the TextureRect
	var color = get_average_color(texture) # Get the average color of the ViewportTexture
	
	var texture2 = sub_viewport_2.get_texture() # Get the ViewportTexture from the SubViewport
	texture_rect_2.texture = texture2
	var color2 = get_average_color(texture2) # Get the average color of the ViewportTexture
	color_rect.color = (color + color2)/2 # Display the average color on the ColorRect
	light_level.value = max(color2.get_luminance(),color.get_luminance()) # Use the average color's brighness as the light level value
#	light_level.value = color.get_luminance()
	target_light_value = light_level.value
	
func _unhandled_input(event):
	# Record relative mouse motion in mouse_delta
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
	if Input.is_action_just_pressed("ui_accept"):
		if is_landable and not is_landed and not is_taking_of:
			is_landing = true
		elif is_landed:
			take_of()

func landed():
	animation_tree.set("parameters/Transition/transition_request","close_wing")
	await get_tree().create_timer(0.625,false).timeout
	is_landed = true
	is_landing = false
	
func take_of():
	is_landed = false
	is_taking_of = true
	animation_tree.set("parameters/Transition/transition_request","open_wing")
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(self,"global_position",global_position + target_land_basis * Vector3.UP * 0.1,1.0)
	tween.tween_property(self,"basis",Basis(),0.5)
	await tween.finished
	is_taking_of = false

func get_average_color(texture: ViewportTexture) -> Color:
	var image = texture.get_image() # Get the Image of the input texture
	image.resize(1, 1, Image.INTERPOLATE_LANCZOS) # Resize the image to one pixel
	return image.get_pixel(0, 0) # Read the color of that pixel

func get_hologram():
	var hologram_nodes = get_tree().get_nodes_in_group(MOSQUETTO_HOLOGRAM_GROUP)
	if hologram_nodes.is_empty():
		var h = MOSQUETTO_HOLOGRAM_SCENE.instantiate()
		get_tree().current_scene.call_deferred("add_child",h)
		return h
	else:
		return hologram_nodes[0]
