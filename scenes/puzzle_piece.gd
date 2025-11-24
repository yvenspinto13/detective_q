extends Control

signal matched(word)
signal fail_match

@export var word: String
@export var match_word: String
@export var is_left: bool = true   # left half (male) vs right half (female)

var dragging = false
var drag_offset = Vector2.ZERO

@onready var label = $TextureRect/Label
@onready var sprite = $TextureRect
var right_scale = 0.24
var left_piece = 0.2


func _ready():
	label.text = word
	label.add_theme_font_size_override("font_size", 150)

	
	# Load correct sprite (male/female)
	if is_left:
		sprite.texture = preload("res://assets/objects/puzzle_piece_male.png") 
		sprite.scale = Vector2(0.2, 0.2)
		label.size = sprite.size
		label.offset_left = 0
	else:
		sprite.texture = preload("res://assets/objects/puzzle_piece_female.png")
		sprite.scale = Vector2(0.24, 0.24)
		label.offset_left = 100
		label.size = sprite.size
	# Make label fill parent (TextureRect)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	label.offset_top = 0
	label.offset_right = 0
	label.offset_bottom = 0
	# Align text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			dragging = true
			drag_offset = event.position
		else:
			dragging = false
			check_for_match()
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - drag_offset

func check_for_match():
	print("checking match")
	for sibling in get_parent().get_children():
		if sibling == self:
			continue
		print("checking sibling", sibling, sibling.word, match_word)
		if sibling is Control and sibling.word == match_word:
			var dist = global_position.distance_to(sibling.global_position)
			print("dist", dist)
			if dist < 161: # snapping distance
				# Snap visually so male and female connect
				print("check pos", sibling.global_position, sprite.texture.get_width())
				if is_left:
					global_position = sibling.global_position + Vector2(-sprite.texture.get_width() + 20, 0)
				else:
					global_position = sibling.global_position + Vector2(sprite.texture.get_width() - 20, 0)
				
				emit_signal("matched", word)
				#mouse_filter = Control.MOUSE_FILTER_IGNORE
				#sibling.mouse_filter = Control.MOUSE_FILTER_IGNORE
				sibling.queue_free()
				queue_free()
			else:
				emit_signal("fail_match")
