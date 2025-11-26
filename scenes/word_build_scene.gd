extends Node2D

signal puzzle_completed(puzzle_name: String)
signal puzzle_restart

@onready var pictures_container := $UI/PuzzleUI/PicturesContainer
@onready var options_container := $UI/PuzzleUI/OptionsContainer

var correct_matches: Dictionary = {
	"PictureDog": "Dog",
	"PictureCat": "Cat",
	"PictureElephant": "Elephant"
}

var selected_picture: TextureButton = null
var base_scales: Dictionary = {}   # Stores original scale for each picture


# ---------------------------------------------------------
#  READY
# ---------------------------------------------------------
func _ready():
	print("Puzzle ready!")

	# Setup pictures
	for pic in pictures_container.get_children():
		if pic is TextureButton:
			_apply_picture_border(pic)

			# Store original scale ONCE
			base_scales[pic.name] = pic.scale

			pic.pressed.connect(Callable(self, "_on_picture_selected").bind(pic))

	# Setup option buttons
	for btn in options_container.get_children():
		if btn is Button:
			_style_option_button(btn)
			btn.pressed.connect(Callable(self, "_on_option_selected").bind(btn))
	if DisplayServer.has_feature(DisplayServer.Feature.FEATURE_TEXT_TO_SPEECH) and len(DisplayServer.tts_get_voices()) > 0:
		DisplayServer.tts_speak("Match the animals! Touch the animal picture and then touch what it is called", GlobalSettings.default_language, GlobalSettings.master_volume, GlobalSettings.speech_pitch, GlobalSettings.speech_rate, 1)
	
	ScoreManager.start_puzzle("tree_house")


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
#  STYLE: Option Buttons (Fix invisible text)
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

	# Apply the same style to ALL possible states
	var states = ["normal", "hover", "pressed", "disabled", "focus", "hover_pressed"]
	for state in states:
		btn.add_theme_stylebox_override(state, style)

	# CRITICAL: Force black text in EVERY possible state
	var black = Color.BLACK
	btn.add_theme_color_override("font_color", black)
	btn.add_theme_color_override("font_hover_color", black)
	btn.add_theme_color_override("font_pressed_color", black)
	btn.add_theme_color_override("font_focus_color", black)
	btn.add_theme_color_override("font_hover_pressed_color", black)  # This one is the real culprit!
	btn.add_theme_color_override("font_disabled_color", Color(0.3, 0.3, 0.3)) # optional: dim when disabled

	# Optional: make sure outline focus is visible but not annoying
	btn.add_theme_color_override("font_outline_color", Color.TRANSPARENT)

# ---------------------------------------------------------
#  PICTURE SELECTED (ZOOM — fixed infinite scaling)
# ---------------------------------------------------------
func _on_picture_selected(picture: TextureButton) -> void:

	# Reset scale of previous selection
	if selected_picture != null:
		_reset_picture_animation(selected_picture)

	selected_picture = picture

	var base_scale: Vector2 = base_scales[picture.name]

	var tween = create_tween()
	tween.tween_property(picture, "scale", base_scale * 1.15, 0.15)

	print("Selected:", picture.name)


# ---------------------------------------------------------
#  RESET PICTURE SCALE
# ---------------------------------------------------------
func _reset_picture_animation(picture: TextureButton):
	var base_scale: Vector2 = base_scales[picture.name]

	var tween = create_tween()
	tween.tween_property(picture, "scale", base_scale, 0.15)

func _apply_correct_style_to_option(option: Button):
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.7, 1.0, 0.7)
	style.set_border_width_all(3)
	style.border_color = Color(0.2, 0.8, 0.2)
	style.set_corner_radius_all(6)

	for state in [
		"normal", "hover", "pressed", "disabled",
		"hover_pressed", "focus", "focus_hover", "focus_pressed"
	]:
		option.add_theme_stylebox_override(state, style)

	option.add_theme_color_override("font_color", Color.BLACK)

# ---------------------------------------------------------
#  OPTION SELECTED (Correct / Wrong Logic)
# ---------------------------------------------------------
func _on_option_selected(option: Button) -> void:
	if selected_picture == null:
		return

	var expected_name: String = correct_matches.get(selected_picture.name, "")
	var chosen_name: String = option.text

	if chosen_name == expected_name:
		# Make green BEFORE animations or disabled state changes
		_apply_correct_style_to_option(option)
		_set_picture_border_color(selected_picture, Color(0.2, 0.8, 0.2))

		# Then run animations
		_correct_answer_animation(selected_picture, option)

		selected_picture.disabled = true
		option.disabled = true
		check_completion()

	else:
		_wrong_answer_animation(option)
		ScoreManager.record_wrong_attempt("tree_house", "Selected wrong picture")
		print("❌ Wrong match!")


# ---------------------------------------------------------
#  WRONG → red flash only
# ---------------------------------------------------------
func _wrong_answer_animation(option: Button):
	var tween = create_tween()
	tween.tween_property(option, "modulate", Color(1, 0.4, 0.4), 0.08)
	tween.tween_property(option, "modulate", Color.WHITE, 0.12)


# ---------------------------------------------------------
#  CORRECT → green border + green button
# ---------------------------------------------------------
func _correct_answer_animation(picture: TextureButton, option: Button):
	_set_picture_border_color(picture, Color(0.2, 0.8, 0.2))

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.7, 1.0, 0.7)
	style.set_border_width_all(3)
	style.border_color = Color(0.2, 0.8, 0.2)
	style.set_corner_radius_all(6)

	for state in ["normal", "hover", "pressed", "disabled"]:
		option.add_theme_stylebox_override(state, style)

	option.add_theme_color_override("font_color", Color.BLACK)

	# After the animation, restore scale
	var tween = create_tween()
	tween.tween_callback(func():
		_reset_picture_animation(picture)
	)


# ---------------------------------------------------------
#  Change picture border color
# ---------------------------------------------------------
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
	ScoreManager.complete_puzzle("tree_house")
	emit_signal("puzzle_completed", "tree_house")


# ---------------------------------------------------------
#  CONFETTI
# ---------------------------------------------------------
func play_confetti():
	var confetti = preload("res://scenes/effect.tscn").instantiate()
	add_child(confetti)
	confetti.get_node("Particles").emitting = true
