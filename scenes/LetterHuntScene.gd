extends Node2D

signal puzzle_completed(clue_id: String)

@onready var letters_container = $LettersContainer
@onready var feedback_label = $Feedback
@onready var basket = $Basket

# Game config
var target_letter = "p"
var distractor_letter = "q"
var total_targets = 5
var collected_targets = 0

func _ready():
	spawn_letters()
	feedback_label.text = "Find all the '%s' letters!" % target_letter

func spawn_letters():
	letters_container.queue_free_children()  # clean old

	var positions = [
		Vector2(200, 200), Vector2(400, 250), Vector2(600, 300),
		Vector2(300, 400), Vector2(500, 450), Vector2(700, 200)
	]
	positions.shuffle()

	for i in range(total_targets + 3): # add some distractors
		var letter = target_letter if i < total_targets else distractor_letter
		var btn = Button.new()
		btn.text = letter
		btn.position = positions[i % positions.size()]
		btn.pressed.connect(Callable(self, "_on_letter_pressed").bind(btn, letter))
		letters_container.add_child(btn)

func _on_letter_pressed(button: Button, letter: String):
	if letter == target_letter:
		button.disabled = true
		button.modulate = Color(0,1,0)  # green
		collected_targets += 1
		feedback_label.text = "Great! Found %s/%s" % [collected_targets, total_targets]
		if collected_targets == total_targets:
			feedback_label.text = "✅ Puzzle solved!"
			emit_signal("puzzle_completed", "signboard")  # clue points to treehouse
	else:
		feedback_label.text = "❌ Oops, that's a '%s' not a '%s'!" % [letter, target_letter]
		button.modulate = Color(1,0,0)  # red
		# play funny boing sound here
