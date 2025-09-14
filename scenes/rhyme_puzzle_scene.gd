extends Node2D

signal puzzle_completed(clue_id: String)
# Example rhyming pairs
var pairs = [
	{"word": "box", "rhyme": "fox"},
	{"word": "tree", "rhyme": "bee"},
	{"word": "cat", "rhyme": "hat"}
]

var matched_pairs = 0

@onready var feedback_label = $Feedback
@onready var word_pairs_container = $WordPairs

func _ready():
	spawn_pairs()

func spawn_pairs():
	var y_offset = 50
	var i = 0
	var y_offsets_left = [50, 250, 450]
	var y_offsets_right = [50, 250, 450]
	y_offsets_left.shuffle()
	y_offsets_right.shuffle()
	print("offsets", y_offsets_left, y_offsets_right)
	for p in pairs:
		# Left piece (male side)
		var left_piece = create_piece(p.word, p.rhyme, true)
		left_piece.position = Vector2(100, y_offsets_left[i])
		word_pairs_container.add_child(left_piece)

		# Right piece (female side)
		var right_piece = create_piece(p.rhyme, p.word, false)
		right_piece.position = Vector2(400, y_offsets_right[i])
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
		emit_signal("puzzle_completed", "toy_box")
