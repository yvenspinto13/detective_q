extends Node2D
signal puzzle_completed(puzzle_name: String)

# Quick references
@onready var letters_container := $UI/PuzzleUI/LettersContainer
@onready var slots_container := $UI/PuzzleUI/SlotsContainer

# game state
var selected_letter : String = ""
var selected_button : Button = null
const CORRECT_WORD := "CAT"

func play_confetti():
	var confetti = preload("res://scenes/effect.tscn").instantiate()
	confetti.position = get_viewport().get_visible_rect().size / 2
	add_child(confetti)
	# Get the actual CPUParticles2D inside the scene
	var particles = confetti.get_node("Particles")  # child node
	particles.emitting = true

func _ready() -> void:
	# connect letter buttons and slot buttons dynamically
	for btn in letters_container.get_children():
		if btn is Button:
			btn.pressed.connect(Callable(self, "_on_letter_pressed").bind(btn))
	for slot in slots_container.get_children():
		if slot is Button:
			slot.pressed.connect(Callable(self, "_on_slot_pressed").bind(slot))

func _on_letter_pressed(button: Button) -> void:
	# pick up a letter (disable the letter button so it's not reused)
	if selected_button:
		# if previously selected, re-enable it (defensive)
		selected_button.disabled = false
		selected_button.modulate = Color(1,1,1,1)

	selected_button = button
	selected_letter = button.text
	button.disabled = true
	button.modulate = Color(1,1,1,0.7) # slight visual feedback

func _on_slot_pressed(slot_button: Button) -> void:
	# place the selected letter into the slot if slot is empty
	if selected_letter == "":
		return
	if slot_button.text == "":
		slot_button.text = selected_letter
		# clear selection
		selected_button = null
		selected_letter = ""
		check_word()

func check_word() -> void:
	var word := ""
	for slot in slots_container.get_children():
		if slot is Button:
			word += slot.text

	if word.length() == CORRECT_WORD.length():
		if word == CORRECT_WORD:
			print("✅ Puzzle solved!")
			play_confetti()
			await get_tree().create_timer(1.0).timeout
			get_tree().change_scene_to_file("res://scenes/Success.tscn")
			emit_signal("puzzle_completed", "tree_house")  # success path
		else:
			print("❌ Wrong word! Resetting...")
			reset_puzzle()  # clear slots and allow retry

func reset_puzzle() -> void:
	# clear slots and re-enable all letters
	for slot in slots_container.get_children():
		if slot is Button:
			slot.text = ""
	for btn in letters_container.get_children():
		if btn is Button:
			btn.disabled = false
			btn.modulate = Color(1,1,1,1)
	selected_letter = ""
	selected_button = null
