extends Node2D

signal puzzle_completed(puzzle_name: String)
signal puzzle_restart

@onready var pictures_container := $UI/PuzzleUI/PicturesContainer
@onready var options_container := $UI/PuzzleUI/OptionsContainer

var correct_matches = {
	"PictureDog": "Dog",
	"PictureCat": "Cat",
	"PictureElephant": "Elephant"
}

var selected_picture: TextureButton = null
var original_scale := Vector2.ONE


# ---------------------------------------------------------
#  READY → apply borders + style buttons
# ---------------------------------------------------------
func _ready():
	print("Puzzle ready!")

	# Add borders to all picture buttons
	for pic in pictures_container.get_children():
		if pic is TextureButton:
			_apply_picture_border(pic)
			pic.pressed.connect(Callable(self, "_on_picture_selected").bind(pic))

	# Style the word buttons
	for btn in options_container.get_children():
		if btn is Button:
			_style_option_button(btn)
			btn.pressed.connect(Callable(self, "_on_option_selected").bind(btn))


# ---------------------------------------------------------
#  STYLE: Picture Border
# ---------------------------------------------------------
func _apply_picture_border(pic: TextureButton):
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.set_border_width_all(4)
	style.border_color = Color.BLACK
	style.set_corner_radius_all(6)

	for state in ["normal", "hover", "pressed", "disabled"]:
		pic.add_theme_stylebox_override(state, style)


# ---------------------------------------------------------
#  STYLE: Option Buttons (white bg)
# ---------------------------------------------------------
func _style_option_button(btn: Button):
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.set_border_width_all(3)
	style.border_color = Color.BLACK
	style.set_corner_radius_all(6)

	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 6
	style.content_margin_bottom = 6

	for state in ["normal", "hover", "pressed", "disabled"]:
		btn.add_theme_stylebox_override(state, style)

	btn.add_theme_color_override("font_color", Color.BLACK)
	btn.add_theme_color_override("font_hover_color", Color.BLACK)
	btn.add_theme_color_override("font_pressed_color", Color.BLACK)
	btn.add_theme_color_override("font_disabled_color", Color.BLACK)


# ---------------------------------------------------------
#  PICTURE SELECTED (ZOOM)
# ---------------------------------------------------------
func _on_picture_selected(picture: TextureButton) -> void:
	if selected_picture:
		_reset_picture_animation(selected_picture)

	selected_picture = picture
	original_scale = picture.scale

	var tween = create_tween()
	tween.tween_property(picture, "scale", original_scale * 1.15, 0.15)

	print("Selected picture:", picture.name)


func _reset_picture_animation(picture: TextureButton):
	var tween = create_tween()
	tween.tween_property(picture, "scale", Vector2.ONE, 0.15)


# ---------------------------------------------------------
#  OPTION SELECTED
# ---------------------------------------------------------
func _on_option_selected(option: Button) -> void:
	if not selected_picture:
		return

	var expected_name = correct_matches.get(selected_picture.name, "")

	if option.text == expected_name:
		_correct_answer_animation(selected_picture, option)
		selected_picture.disabled = true
		option.disabled = true
		check_completion()
	else:
		_wrong_answer_animation(option)
		print("❌ Wrong match!")


# ---------------------------------------------------------
#  WRONG → red flash only
# ---------------------------------------------------------
func _wrong_answer_animation(option: Button):
	var tween = create_tween()

	# Red flash
	tween.tween_property(option, "modulate", Color(1, 0.4, 0.4), 0.08)
	tween.tween_property(option, "modulate", Color.WHITE, 0.12)


# ---------------------------------------------------------
#  CORRECT → green border + green button
# ---------------------------------------------------------
func _correct_answer_animation(picture: TextureButton, option: Button):
	# Green border for picture
	_set_picture_border_color(picture, Color(0.2, 0.8, 0.2))

	# Green check button
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.7, 1.0, 0.7)  # light green
	style.set_border_width_all(3)
	style.border_color = Color(0.2, 0.8, 0.2)
	style.set_corner_radius_all(6)

	for state in ["normal", "hover", "pressed", "disabled"]:
		option.add_theme_stylebox_override(state, style)

	option.add_theme_color_override("font_color", Color.BLACK)

	var tween = create_tween()
	tween.tween_callback(func():
		_reset_picture_animation(picture)
	)


# Change border color after correct match
func _set_picture_border_color(pic: TextureButton, color: Color):
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color.TRANSPARENT
		style.set_border_width_all(4)
		style.border_color = color
		style.set_corner_radius_all(6)
		pic.add_theme_stylebox_override(state, style)


# ---------------------------------------------------------
#  PUZZLE COMPLETION
# ---------------------------------------------------------
func check_completion() -> void:
	for pic in pictures_container.get_children():
		if pic is TextureButton and not pic.disabled:
			return

	play_confetti()
	await get_tree().create_timer(1.0).timeout
	emit_signal("puzzle_completed", "tree_house")


# ---------------------------------------------------------
#  CONFETTI (properly centered)
# ---------------------------------------------------------
func play_confetti():
	var confetti = preload("res://scenes/effect.tscn").instantiate()

	# Center using root viewport
	# confetti.global_position = get_tree().root.size / 2

	add_child(confetti)
	confetti.get_node("Particles").emitting = true
