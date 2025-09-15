extends Control


signal puzzle_completed(clue_id: String)

# --- Editor-exposed config ---
@export var target_pair: Array[String] = ["p", "q"]         # pair to find
@export_range(8, 20, 1) var tile_count: int = 12           # total tiles to show
@export var min_target_occurrences: int = 4                # minimum number of target tiles combined
@export var max_target_occurrences: int = 8                # maximum number of target tiles combined

# Optional audio feedback (assign AudioStreamPlayers in editor)
#@export var success_sound: AudioStream
#@export var error_sound: AudioStream
@export var collect_anim_time: float = 0.25

# --- nodes ---
@onready var grid: GridContainer = $GridContainer
@onready var target_label: Label = $Label

# internal state
var _target_letters: Array[String] = []
var _tiles_total_targets: int = 0
var _collected_count: int = 0
var _tile_buttons: Array[Button] = []
var _expected_counts: Dictionary = {}   # expected occurrences per target letter (from generated pool)
var _collected_counts: Dictionary = {}  # counts collected so far per target letter

func _ready() -> void:
	randomize()
	if target_pair.size() < 1 or target_pair.size() > 2:
		push_error("target_pair must contain 1 or 2 letters (e.g. ['b'] or ['p','q']).")
		return
	# normalize
	var normalized:Array[String]= []
	for t in target_pair:
		normalized.append(str(t).to_lower())
	target_pair = normalized
	grid.offset_top = 50
	_update_target_display()
	_generate_and_populate(target_pair)

# Public: regenerate with a new pair (or single letter)
func regenerate_with_pair(new_pair: Array[String]) -> void:
	if new_pair.size() < 1 or new_pair.size() > 2:
		push_error("regenerate_with_pair expects 1 or 2 letters.")
		return
	clear_grid()
	_update_target_display()
	_generate_and_populate(target_pair)

# --- generation core ---
func _generate_and_populate(pair: Array[String]) -> void:
	_target_letters = pair
	# choose how many target tiles to generate in total
	var target_occurrences := randi_range(min_target_occurrences, max_target_occurrences)
	# ensure at least one of each target letter (if pair), and leave at least 1 distractor
	target_occurrences = clamp(target_occurrences, _target_letters.size(), max(_target_letters.size(), tile_count - 1))
	_tiles_total_targets = target_occurrences
	_collected_counts.clear()
	_expected_counts.clear()
	_tile_buttons.clear()
	clear_grid()

	# Build initial pool with guaranteed occurrences:
	var pool: Array[String] = []
	# ensure every target appears at least once
	for t in _target_letters:
		pool.append(t)

	var remaining_targets = target_occurrences - _target_letters.size()
	for i in remaining_targets:
		pool.append(_target_letters[randi() % _target_letters.size()])

	# Fill remaining tiles with distractors biased toward confusing letters
	var distractors = _get_distractors_for(_target_letters)
	while pool.size() < tile_count:
		pool.append(distractors[randi() % distractors.size()])

	pool.shuffle()

	# Create buttons from pool
	for letter in pool:
		var btn = _create_tile_button(letter)
		grid.add_child(btn)
		_tile_buttons.append(btn)

	# compute expected counts from generated pool (so UI shows "remaining")
	for t in _target_letters:
		_expected_counts[t] = 0
		_collected_counts[t] = 0
	for letter in pool:
		if letter in _target_letters:
			_expected_counts[letter] += 1

	_update_target_display()

# Remove all tiles
func clear_grid() -> void:
	for child in grid.get_children():
		child.queue_free()
	_tile_buttons.clear()

# --- UI tile creation & handlers ---
func _create_tile_button(letter: String) -> Button:
	var btn := Button.new()
	btn.focus_mode = Control.FOCUS_NONE
	btn.text = str(letter)
	btn.add_theme_font_size_override("font_size", 24) 
	#btn.expand = true
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn.custom_minimum_size=Vector2(128, 128)
	btn.set_meta("letter", letter.to_lower())
	btn.connect("pressed", Callable(self, "_on_tile_pressed").bind(btn))
	return btn

func _on_tile_pressed(btn: Button) -> void:
	var letter = str(btn.get_meta("letter")).to_lower()
	if letter in _target_letters:
		_handle_correct_tile(btn, letter)
	else:
		_handle_incorrect_tile(btn)

func _handle_correct_tile(btn: Button, letter: String) -> void:
	_collected_counts[letter] += 1
	# disable & animate removal
	btn.disabled = true
	var tween = create_tween()
	tween.tween_property(btn, "rect_scale", Vector2(0.7, 0.7), collect_anim_time)
	tween.tween_property(btn, "modulate:a", 0.0, 0.20).set_delay(collect_anim_time)
	tween.tween_callback(Callable(btn, "queue_free"))

	# play success sound (if provided)
	#if success_sound:
		#var sp := AudioStreamPlayer.new()
		#add_child(sp)
		#sp.stream = success_sound
		#sp.play()
		## free after 1.2s
		#await get_tree().create_timer(1.2).timeout
		#sp.queue_free()

	_update_target_display()

	# check completion
	var collected_total = 0
	var expected_total = 0
	for k in _target_letters:
		collected_total += _collected_counts.get(k, 0)
		expected_total += _expected_counts.get(k, 0)
	print("deets", _collected_counts, _expected_counts, collected_total, expected_total)
	if collected_total >= expected_total:
		# tiny delay so last animations play
		target_label.text="Success!! Puzzle Completed"
		await get_tree().create_timer(1.0).timeout
		_on_puzzle_complete()

func _handle_incorrect_tile(btn: Button) -> void:
	# shake animation
	print("button", btn.position.x)
	var orig_x = btn.position.x
	var tween = create_tween()
	tween.tween_property(btn, "position:x", orig_x - 6, 0.05)
	tween.tween_property(btn, "position:x", orig_x + 8, 0.10)
	tween.tween_property(btn, "position:x", orig_x, 0.05)
	# error sound
	#if error_sound:
		#var sp := AudioStreamPlayer.new()
		#add_child(sp)
		#sp.stream = error_sound
		#sp.play()
		## free after short delay
		#await get_tree().create_timer(0.9).timeout
		#sp.queue_free()

# --- update target label to show remaining counts ---
func _update_target_display() -> void:
	if not target_label:
		return
	var parts: Array[String] = []
	for t in _target_letters:
		var expected = _expected_counts.get(t, 0)
		var collected = _collected_counts.get(t, 0)
		var left = max(expected - collected, 0)
		parts.append("%s (%d)" % [t, left])
	if parts.size() == 1:
		target_label.text = "Find: %s" % parts[0]
	else:
		#target_label.text = "Find: %s" % ", ".join(parts)
		target_label.text = "Detective! We need the letters %s. \nWatch out for tricky letters—they’ll slow us down!" % ", ".join(parts)

# --- called when all collected ---
func _on_puzzle_complete() -> void:
	# optional celebration (connect your own AnimationPlayer or popup)
	if has_node("CelebratePlayer"):
		$CelebratePlayer.play("celebrate")
	print("puzzle complete")
	emit_signal("puzzle_completed", "signboard")

# --- distractor builder (biased to confusing letters) ---
func _get_distractors_for(targets: Array[String]) -> Array[String]:
	# confusion map: list visually-similar distractors for each letter
	var confusion_map = {
		"b": ["d","p","q"],
		"d": ["b","p","q"],
		"p": ["q","b","d"],
		"q": ["p","b","d"],
		"m": ["n"],
		"n": ["m"],
		"u": ["v"],
		"v": ["u"],
		"s": ["z"],
		"z": ["s"],
		# you can extend these pairs as needed
	}

	var combined:Array[String] = []
	# add visually-similar distractors first (more weight)
	for t in targets:
		if confusion_map.has(t):
			for s in confusion_map[t]:
				if s in targets:
					continue
				# add multiple times to bias selection
				combined.append(s)
				combined.append(s)

	# add a broader general pool (excluding the targets themselves)
	var general = ["a","c","e","g","h","i","k","l","o","r","t","w","x","y"]
	# make sure we don't include the target letters in general
	for t in targets:
		if t in general:
			general.erase(t)

	# add general letters once
	for g in general:
		combined.append(g)

	# If combined is empty (no mapping), fill with basic letters (safe fallback)
	if combined.is_empty():
		combined = ["a","c","e","o","r","t","l","n","m","s","z"]

	combined.shuffle()
	return combined

# --- small helper ---
func randi_range(min_v: int, max_v: int) -> int:
	return int(randf_range(float(min_v), float(max_v + 1)))
