extends Control

# Emitted when puzzle solved. MainLevel should connect to this.
signal puzzle_completed(clue_id: String)

@export var clue_id: String = "cat_collar"  # set in editor per-puzzle
# Option list: name + path to audio (edit these to match your files)
var options_data := ["cat", "hat", "rat", "bat"]

# runtime
var shuffled := []
var correct_index: int = -1
var solved: bool = false
var old_drop: StyleBox = null

# List of draggable piece nodes (instantiate them in _ready)
var word_pieces: Array = []

@onready var zones := [
	$DropZones/TopLeft,
	$DropZones/TopRight,
	$DropZones/BottomLeft,
	$DropZones/BottomRight
]

@onready var ref_player: AudioStreamPlayer = $RefPlayer

func play_confetti():
	var confetti = preload("res://effects/effect.tscn").instantiate()
	confetti.position = get_viewport().get_visible_rect().size / 2
	add_child(confetti)
	# Get the actual CPUParticles2D inside the scene
	var particles = confetti.get_node("Particles")  # child node
	particles.emitting = true

func _ready() -> void:
	# build UI and start the round
	randomize()
	_setup_round()

func _setup_round() -> void:
	# create shuffled copy
	shuffled = options_data.duplicate()
	shuffled.shuffle()
	# load reference stream, this should be based on level
	var ref_path = "res://audio/cat.ogg"
	ref_player.stream = load(ref_path)
	# Assign shuffled words to zone labels
	for i in zones.size():
		var zone = zones[i]
		var label = zone.get_node("Label")
		print("assign label", label)
		label.text = shuffled[i]
	ref_player.play()

func _receive_drop(drop_target: Panel) -> void:
	if drop_target:
		print("received", drop_target)
		var label = drop_target.get_node("Label")
		var isSuccess = false
		if label.text == "cat":
			print("success")
			isSuccess = true
		
		old_drop= drop_target.get_theme_stylebox("panel")
		print(old_drop)
		old_drop.border_width_left = 5
		old_drop.border_width_right = 5
		old_drop.border_width_top = 5
		old_drop.border_width_bottom = 5
		if isSuccess:
			old_drop.border_color = Color(0, 1, 0)
			play_confetti()
			await get_tree().create_timer(1.0).timeout
			emit_signal("puzzle_completed", "gate" )
		else: 
			old_drop.border_color = Color(1, 0, 0)

func _start_drag() -> void:
	if old_drop:
		old_drop.border_width_left = 0
		old_drop.border_width_right = 0
		old_drop.border_width_top = 0
		old_drop.border_width_bottom = 0
