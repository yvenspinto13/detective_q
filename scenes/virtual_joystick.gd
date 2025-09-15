extends Area2D

@export var max_distance := 80.0 # How far the knob can move from the center
@onready var knob: Sprite2D = $Base/Knob
@onready var base: Sprite2D = $Base
var is_dragging := false
var move_direction := Vector2.ZERO

func _input(event):
	# Check for touch input
	if event is InputEventScreenTouch:
		if event.pressed:
			if base.global_position.distance_to(event.position) < max_distance:
				is_dragging = true
		else:
			is_dragging = false
			knob.position = Vector2.ZERO
			move_direction = Vector2.ZERO
	
	# Check for mouse input (if testing on desktop)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if base.global_position.distance_to(event.position) < max_distance:
				is_dragging = true
		else:
			is_dragging = false
			knob.position = Vector2.ZERO
			move_direction = Vector2.ZERO

func _process(delta):
	if is_dragging:
		var touch_pos = get_global_mouse_position()
		var offset = touch_pos - base.global_position
		#print("joystick: drag", offset)
		
		# Clamp the knob's position within the maximum distance
		knob.position = offset.limit_length(max_distance)
		
		# Calculate and normalize the movement vector
		move_direction = offset.normalized()

# Function for the player to get the movement direction
func get_move_direction() -> Vector2:
	return move_direction
