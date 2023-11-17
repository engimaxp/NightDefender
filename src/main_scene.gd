extends Node

var elapsed = 0
const music = preload("res://asset/music/DayAndNight.wav")
@onready var score_label = $ScoreLabel
var current_score:float = 0
var target_score:float = 0
# `pre_start()` is called when a scene is loaded.
# Use this function to receive params from `Game.change_scene(params)`.

func score_change(score):
	target_score += score

func _process(delta):
	if is_instance_valid(score_label):
		current_score = float(ceil(lerp(current_score,target_score,delta)))
		score_label.text = "Score\n"+ str(int(current_score))

func pre_start(params):
	Signals.add_points.connect(score_change)
	SoundManager.play_music(music)
	var cur_scene: Node = get_tree().current_scene
	print("Scene loaded: ", cur_scene.name, " (", cur_scene.scene_file_path, ")")
	if params:
		for key in params:
			var val = params[key]
			printt("", key, val)
#	$Sprite2D.position = Game.size / 2


# `start()` is called after pre_start and after the graphic transition ends.
func start():
	print("gameplay.gd: start() called")
	Signals.scene_pre_start.emit()

