extends SplashContainer


func _on_finished_all_splash_screen():
	if move_to_scene != null:
		ScreenFade.change_scene(move_to_scene,\
		ScreenFade.FadeType.Blend,1.0,Constants.SWITCH_SCENE_TEXTURE)
	else:
		push_error("Please set move_to_scene in SplashContainer")
