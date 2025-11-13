extends CanvasLayer

func _on_touch_screen_left_button_pressed() -> void:
	Input.action_press("left")

func _on_touch_screen_left_button_released() -> void:
	Input.action_release("left")


func _on_touch_screen_right_button_pressed() -> void:
	Input.action_press("right")


func _on_touch_screen_right_button_released() -> void:
	Input.action_release("right")


func _on_touch_screen_up_button_pressed() -> void:
	Input.action_press("jump")


func _on_touch_screen_up_button_released() -> void:
	Input.action_release("jump")
