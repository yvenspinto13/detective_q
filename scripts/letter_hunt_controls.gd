extends CanvasLayer



func _handle_touch_event(event: InputEvent, action) -> void:
	if event is InputEventMouseButton:
		# Check if it's a left button press (standard for clicks/touches)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				Input.action_press(action)
				# Add logic for when the element is pressed down
			elif event.is_released():
				# Add logic for when the press/touch ends
				Input.action_release(action)


func _on_up_button_gui_input(event: InputEvent) -> void:
	# This block handles both mouse clicks AND touch presses
	_handle_touch_event(event, "jump")


func _on_left_button_gui_input(event: InputEvent) -> void:
	_handle_touch_event(event, "left")


func _on_right_button_gui_input(event: InputEvent) -> void:
	_handle_touch_event(event,"right")
