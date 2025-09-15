extends Node2D

signal puzzle_completed(clue_id: String)
# Example rhyming pairs
var pairs = [
	{"word": "box", "rhyme": "fox"},
	{"word": "tree", "rhyme": "bee"},
	{"word": "cat", "rhyme": "hat"}
]

var matched_pairs = 0

@onready var feedback_label = $PuzzleArea/PanelContainer/Feedback
@onready var word_pairs_container = $WordPairs

func play_confetti():
	var confetti = preload("res://scenes/effect.tscn").instantiate()
	confetti.position = get_viewport().get_visible_rect().size / 2
	add_child(confetti)
	# Get the actual CPUParticles2D inside the scene
	var particles = confetti.get_node("Particles")  # child node
	print("confetti callledddd..2.")
	particles.emitting = true

func _ready():
	spawn_pairs()

func spawn_pairs():
	var y_offset = 120
	var i = 0
	var x_offset = get_viewport_rect().size.x/2
	var y_offsets_left = [80, 250, 430]
	var y_offsets_right = [80, 250, 430]
	y_offsets_left.shuffle()
	y_offsets_right.shuffle()
	print("offsets", y_offsets_left, y_offsets_right)
	for p in pairs:
		# Left piece (male side)
		var left_piece = create_piece(p.word, p.rhyme, true)
		left_piece.position = Vector2(x_offset - 300, y_offsets_left[i])
		word_pairs_container.add_child(left_piece)

		# Right piece (female side)
		var right_piece = create_piece(p.rhyme, p.word, false)
		right_piece.position = Vector2(x_offset+100, y_offsets_right[i])
		word_pairs_container.add_child(right_piece)

		y_offset += 200
		i+=1

func create_piece(word: String, match_word: String, is_left: bool) -> Control:
	var piece = preload("res://scenes/PuzzlePiece.tscn").instantiate()
	piece.word = word
	piece.match_word = match_word
	piece.is_left = is_left
	piece.connect("matched", Callable(self, "_on_piece_matched"))
	return piece

func _on_piece_matched(word):
	matched_pairs += 1
	feedback_label.text = "Matched: %s!" % word

	if matched_pairs == pairs.size():
		feedback_label.text = "All rhymes matched! Puzzle solved!"
		play_confetti()
		await get_tree().create_timer(1.0).timeout
		emit_signal("puzzle_completed", "toy_box")
