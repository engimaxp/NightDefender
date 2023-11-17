extends ProgressBar
var current_health:float = 100
var max_health:float = 100
var target_health:float = 100
var is_dead = false:
	set(v):
		var diff = is_dead != v
		is_dead = v
		if diff and is_dead:
			Signals.game_over.emit()
var state = 0 # 0 idle 1 losing health 2 adding health

func _ready():
	value = 1

func _process(delta):
	if state == 1:
		target_health -= delta
		if target_health <= 0:
			state = 0
	elif state == 2:
		target_health += delta * 20
		if target_health >= max_health:
			state = 0
	target_health = clamp(target_health,0,max_health)
	
	if current_health != target_health:
		current_health = lerp(current_health,target_health,delta)
	current_health = clamp(current_health,0,max_health)
	self.value = current_health / max_health
	if current_health <= 0:
		is_dead = true
		Signals.game_over.emit()
	
func start_adding_health():
	state = 2
func stop_adding_health():
	state = 0
	
func start_losing_health():
	state = 1
func stop_losing_health():
	state = 0

func lose_health(v):
	target_health -= v
