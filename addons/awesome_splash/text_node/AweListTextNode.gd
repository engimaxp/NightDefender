extends Node2D
class_name AweListTextNode

@export var font: Font
@export var anchor: Vector2 = Vector2.ZERO
@export var char_anchor: Vector2 = Vector2.ZERO
@export var space_character: float = 0
@export var font_size:int
@export var text: String :set = _set_text,get = _get_text

var list_text_node: Array = []

var width = 0.0
var height = 0.0

var text_container: Node2D

func _init(font: Font = null, anchor := Vector2.ZERO, char_anchor := Vector2.ZERO, space_character: float = 0.0):
	self.font = font
	self.anchor = anchor
	self.char_anchor = char_anchor
	self.space_character = space_character
	text_container = Node2D.new()
	add_child(text_container)


func _ready():
	# I don't know why in the first the func _create_list_text_node have set width = 0.0 
	if text != null:
		self.text = text


func _set_text(value: String):
	text = value
	_create_list_text_node(value)
#	update()


func _get_text() -> String:
	return text


func get_all_text_node() -> Array:
	return list_text_node


func get_reverse_text_node() -> Array:
	var arr = []
	for x in list_text_node.size():
		arr.append(list_text_node[-x-1])
	return arr


func update_all_anchor(list_anchor: Array):
	for x in list_text_node.size():
		list_text_node[x].update_anchor(list_anchor[x])

# Debug
#func _draw():
#	draw_rect(Rect2(-10, -10, 20, 20), Color.yellow)


func _create_char_node(text: String, font: Font, char_anchor: Vector2):
	var text_node = AweTextNode.new(char_anchor, font)
	list_text_node.append(text_node)
	text_container.add_child(text_node)
	text_node.text = text
	text_node.font_size = font_size
	return text_node


func _remove_all_text_node():
	for text_node in list_text_node:
		text_container.remove_child(text_node)
		text_node.queue_free()
	list_text_node = []


func _create_list_text_node(text: String):
	_remove_all_text_node()
	
	width = 0.0
	height = 0.0
	
	if text == "":
		return

	for character in text:
		var char_node = _create_char_node(character, font, char_anchor)
		var tl =  char_node.get_coordinates_top_left_char()
		char_node.position.x = width - tl.x
		char_node.position.y = -tl.y
		width += ( char_node.get_true_size()).x + space_character

	width -= space_character
	height = ( list_text_node[0].get_true_size()).y

	_update_layout(anchor)


func _update_layout(anchor: Vector2):
	var x =  -width * anchor.x
	var y =  -height * anchor.y
	text_container.position = Vector2(x, y)
