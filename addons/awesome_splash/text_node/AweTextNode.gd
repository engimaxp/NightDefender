extends Node2D
class_name AweTextNode

@export var anchor: Vector2
@export var font: Font :set = _set_font
@export var text: String : set = _set_text, get = _get_text
@export var font_size:int :set = _set_font_size

func _set_font_size(val):
	font_size = val
	if is_instance_valid(label):
		label.set("theme_override_font_sizes/font_size",font_size)

var label: Label

func _init(anchor: Vector2 = Vector2.ZERO, dynamic_font: Font = null):
	label = Label.new()
	label.horizontal_alignment = 1 # Center
	label.vertical_alignment = 1 # Center
	if dynamic_font != null:
		label.set("theme_override_fonts/font",dynamic_font)
	add_child(label)
	self.anchor = anchor
	self.font = dynamic_font


func _ready():
	if font != null:
		label.set("custom_fonts/font", font)
		_update_layout()


func _set_font(value):
	font = value
	label.set("custom_fonts/font", value)
	_update_layout()


func _set_text(value: String):
	text = value
	label.text = value
	_update_layout()
#	update()


func _get_text() -> String:
	return text


#func _draw():
#	draw_rect(Rect2(-5, -5, 10, 10), Color.blue)


func get_true_size() -> Vector2:
#	print(label.size.x, label.size.y * 0.64)
	return Vector2(label.size.x, label.size.y * 0.64)


func get_coordinates_top_left_char() -> Vector2:
	var true_size =  get_true_size()
	return Vector2(-true_size.x * anchor.x, -true_size.y * anchor.y)


func _update_layout():
	var label_rect = label.size
	var true_size =  get_true_size()
	
	var x = -(label_rect.x - true_size.x) / 2.0 - true_size.x * anchor.x
	var y = -(label_rect.y - true_size.y) / 2.0 - true_size.y * anchor.y
	label.position = Vector2(x, y)


# CHUA TEST LAI
func update_anchor(new_anchor: Vector2):
	if new_anchor == anchor:
		return
		
	var true_size =  get_true_size()
	
	var diff_anchor = new_anchor - anchor
	var shift_x = true_size.x * diff_anchor.x
	var shift_y = true_size.y * diff_anchor.y
	
	label.position.x -= shift_x
	label.position.y -= shift_y
	
	position.x += shift_x
	position.y += shift_y
