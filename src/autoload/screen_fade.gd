extends CanvasLayer

signal pre_transition
signal post_transition

@onready var textureNode = $FadeSceneTexture

enum FadeType {
	Instant, # immediately change
	CrossFade, # naively fade in the new scene
	Blend # alpha blend one into the other using a texture to control the fade
}

func _ready():
	textureNode.fade_done.connect(change_scene_complete)
	
func change_scene(new_scene:String, fade_type, fade_time_seconds:float = 1.0, shader_image:CompressedTexture2D = null) -> void:
	if new_scene == null:
		push_error("Can't change scene to null scene!")	
	if fade_type == FadeType.Blend and shader_image == null:
		push_error("You need to specify a shader image for blending!")
	
	_common_pre_fade(fade_type, fade_time_seconds, shader_image)
	_set_scene(new_scene)
	emit_signal("pre_transition")

	_common_wait_for_fade(fade_type, fade_time_seconds)

func _common_wait_for_fade(fade_type, fade_seconds:float) -> void:	
	if fade_type == FadeType.Instant:
		fade_seconds = 0.0
		change_scene_complete()
	if fade_type == FadeType.CrossFade or fade_type == FadeType.Instant:
		var tween = create_tween()
		tween.interpolate_property(textureNode, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), fade_seconds)
		await tween.finished
		change_scene_complete()
	elif fade_type == FadeType.Blend:
		textureNode.start()
	else:
		push_error("Missing implementation in _common_wait_for_fade for fade-type %s" % fade_type)


func _common_post_fade() -> void:
	textureNode.hide()
#	if is_instance_valid(textureNode.texture):
#		textureNode.texture.unreference()
	pass
	
func change_scene_complete():
	_common_post_fade()
	emit_signal("post_transition")

func _take_screenshot()->ImageTexture:
	var image:Image = get_tree().root.get_texture().get_image()
	# Flip it on the y-axis (because it's flipped)
	image.flip_y()
	
	var image_texture = ImageTexture.create_from_image(image)
#	image_texture.flags = 0 # turn off "Filter" so it's pixel perfect
	return image_texture
	
func _common_pre_fade(fade_type, fade_time_seconds:float, shader_image:CompressedTexture2D = null):
	var screenshot:ImageTexture = _take_screenshot()
	textureNode.fade_time_seconds = fade_time_seconds
	textureNode.texture = screenshot
	
	textureNode.show()
	# Needed because changing texture on one instance seems to change all of them
	if fade_type == FadeType.Blend:
		textureNode.material.set("shader_parameter/dissolve_texture", shader_image)

func _set_scene(new_scene:String):
	var previous_scene = get_tree().current_scene
	previous_scene.queue_free()
	print("killed previous scene %s" % previous_scene)
	get_tree().change_scene_to_file(new_scene)
