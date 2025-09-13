extends Node2D

# Quick references
@onready var letters_container := $UI/PuzzleUI/LettersContainer
@onready var slots_container := $UI/PuzzleUI/SlotsContainer

# game state
var selected_letter : String = ""
var selected_button : Button = null
const CORRECT_WORD := "CAT"

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
			get_tree().change_scene_to_file("res://scenes/Success.tscn")
		else:
			print("❌ Wrong word!")
			get_tree().change_scene_to_file("res://scenes/Failure.tscn")

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
