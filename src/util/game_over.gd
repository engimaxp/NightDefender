extends CanvasLayer

@onready var pause := $PauseOverlay
@onready var score = $PauseOverlay/VBoxOptions/Score
@onready var restart = $PauseOverlay/VBoxOptions/Restart

var fp = 0.0

func _ready():
	pause.hide()
	Signals.game_over.connect(show_game_over)
	Signals.add_points.connect(cal_points)

func cal_points(p):
	fp += p

func show_game_over():
	pause.show()
	score.text = "Score: " + str(int(fp))
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# when the node is removed from the tree (mostly because of a scene change)
func _exit_tree() -> void:
	# disable pause
#	get_tree().paused = false
	pass


func _on_main_menu_pressed():
	Game.change_scene_to_file("res://scenes/menu/menu.tscn", {"show_progress_bar": false})


func _on_restart_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Game.restart_scene()
